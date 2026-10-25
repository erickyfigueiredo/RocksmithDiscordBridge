import unittest
from tools.prune_previews import obsolete_previews


def release(number, draft=False, prerelease=True):
    return dict(id=number, tag_name=f'v0.3.2-preview.{number}', draft=draft, prerelease=prerelease,
                published_at=f'2026-01-{number:02d}T00:00:00Z',
                assets=[{'name': n} for n in ('RocksmithDiscordBridge-Setup-x64.exe', 'SHA256SUMS.txt')])


class RetentionTests(unittest.TestCase):
    def test_keeps_current_previous_and_stable_releases(self):
        items = [release(1, draft=True), release(2), release(3), release(4), release(5, prerelease=False)]
        self.assertEqual([r['id'] for r in obsolete_previews(items, items[3]['tag_name'])], [1, 2])

    def test_missing_or_incomplete_current_release_blocks_deletion(self):
        items = [release(1), release(2)]
        with self.assertRaises(ValueError):
            obsolete_previews(items, 'v0.3.2-preview.3')
        items[1]['assets'] = []
        with self.assertRaises(ValueError):
            obsolete_previews(items, items[1]['tag_name'])

    def test_older_run_cannot_delete_newer_release(self):
        with self.assertRaises(ValueError):
            obsolete_previews([release(1), release(2)], 'v0.3.2-preview.1')

    def test_other_drafts_are_not_deleted(self):
        other = dict(id=0, tag_name='planned-feature', draft=True)
        self.assertEqual(obsolete_previews([other, release(1)], 'v0.3.2-preview.1'), [])

    def test_future_preview_draft_is_not_deleted(self):
        self.assertEqual(obsolete_previews([release(1), release(2, draft=True)], 'v0.3.2-preview.1'), [])
