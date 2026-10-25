"""Include runtime and bundler license texts with the Windows distribution."""
from importlib.metadata import distribution
from pathlib import Path
import shutil
import sys
import sysconfig

root = Path(__file__).resolve().parents[1]
output = root / 'licenses'
output.mkdir(exist_ok=True)
for name in ('numpy', 'sounddevice', 'Pillow', 'windows-capture', 'opencv-python', 'cffi', 'pycparser', 'pyinstaller'):
    dist = distribution(name)
    for relative in dist.files or []:
        lowered = str(relative).lower()
        if any(word in lowered for word in ('license', 'copying', 'copyright')):
            source = Path(dist.locate_file(relative)).resolve()
            if source.is_file() and source.suffix.lower() not in ('.py', '.pyc', '.pyd', '.dll'):
                destination = output / name / str(relative).replace('../', '').replace('..\\', '')
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, destination)
python_licenses = [Path(sys.base_prefix) / 'LICENSE.txt', Path(sys.base_prefix) / 'LICENSE', Path(sysconfig.get_path('stdlib')) / 'LICENSE.txt']
source = next((path for path in python_licenses if path.is_file()), None)
if source is None:
    raise FileNotFoundError('CPython LICENSE.txt not found')
shutil.copyfile(source, output / 'Python-LICENSE.txt')
print('Collected third-party license texts in', output)
