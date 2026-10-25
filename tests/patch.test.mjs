import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {patchClient} from '../tools/patch.mjs';
const cpp = fs.readFileSync(new URL('./fixtures/RSAsioAudioClient.cpp', import.meta.url), 'utf8');
const header = fs.readFileSync(new URL('./fixtures/RSAsioAudioClient.h', import.meta.url), 'utf8');

test('patches actual RS_ASIO v0.7.4 after volume and before output copy', () => {
  const result = patchClient(cpp, header);
  const start = result.cpp.indexOf('void RSAsioAudioClient::OnAsioBufferSwitch');
  const volume = result.cpp.indexOf('AudioProcessing::DoSoftwareVolumeDsp(', start);
  const publish = result.cpp.indexOf('m_StreamTap.Publish(', start);
  const nativeCopy = result.cpp.indexOf('for (DWORD asioCh', start);
  const input = result.cpp.indexOf('for (WORD ch', start);
  assert.ok(volume < publish && publish < nativeCopy && nativeCopy < input);
  assert.equal(result.cpp.match(/m_StreamTap.Publish/g).length, 1);
  assert.ok(result.header.includes('rsbridge::Tap m_StreamTap;'));
  // Existing output channel conversion and software volume calls are preserved byte-for-byte.
  const relevant = /AudioProcessing::(?:CopyConvertFormat|DoSoftwareVolumeDsp)\([\s\S]*?\);/g;
  assert.deepEqual(result.cpp.match(relevant), cpp.match(relevant));
  assert.equal(result.cpp.match(/m_StreamTap.Initialize/g).length, 1);
  assert.ok(result.cpp.indexOf('m_StreamTap.Initialize') < result.cpp.indexOf('m_AsioSharedHost.AddBufferSwitchListener(this)'));
});
test('refuses duplicate install and source drift rather than patching blindly', () => {
  const once = patchClient(cpp, header);
  assert.throws(() => patchClient(once.cpp, once.header), /modificada/);
  assert.throws(() => patchClient(cpp.replace('m_UsingEventHandle = useEventCallback;', 'changed();'), header), /única/);
  assert.throws(() => patchClient(cpp, header.replace('WAVEFORMATEXTENSIBLE m_WaveFormat;', 'changed;')), /única/);
});
