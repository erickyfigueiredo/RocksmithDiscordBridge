"""Retain the current and previous automated previews; never delete Git tags."""
import argparse
import json
import os
import re
import subprocess

PREVIEW = re.compile(r'^v\d+\.\d+\.\d+-preview\.\d+$')


def obsolete_previews(releases, current_tag):
    current = next((r for r in releases if r['tag_name'] == current_tag), None)
    required = {'RocksmithDiscordBridge-Setup-x64.exe', 'SHA256SUMS.txt'}
    if (not current or current.get('draft') or not current.get('prerelease')
            or not PREVIEW.fullmatch(current_tag)
            or not required.issubset({a['name'] for a in current.get('assets', [])})):
        raise ValueError('The current published installer and checksums must exist before pruning.')
    previews = [r for r in releases if PREVIEW.fullmatch(r['tag_name'])]
    published = sorted((r for r in previews if not r.get('draft') and r.get('prerelease')),
                       key=lambda r: r.get('published_at') or '', reverse=True)
    if not published or published[0]['tag_name'] != current_tag:
        raise ValueError('Only the newest preview may prune older releases.')
    keep = {r['id'] for r in published[:2]}
    current_run = int(current_tag.rsplit('.', 1)[1])
    return [r for r in previews if r['id'] not in keep and
            ((r.get('draft') and int(r['tag_name'].rsplit('.', 1)[1]) < current_run)
             or (not r.get('draft') and r.get('prerelease')))]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current-tag', required=True)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    repository = os.environ['GITHUB_REPOSITORY']
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', repository):
        raise ValueError('Invalid repository identifier')
    releases = []
    page = 1
    while True:
        result = subprocess.run(['gh', 'api', f'repos/{repository}/releases?per_page=100&page={page}'],
                                check=True, capture_output=True, text=True)
        batch = json.loads(result.stdout)
        releases.extend(batch)
        if len(batch) < 100:
            break
        page += 1
    for release in obsolete_previews(releases, args.current_tag):
        release_id = int(release['id'])
        print(('Removing' if args.apply else 'Would remove'), release['tag_name'], flush=True)
        if args.apply:
            subprocess.run(['gh', 'api', '--method', 'DELETE', f'repos/{repository}/releases/{release_id}'], check=True)


if __name__ == '__main__':
    main()
