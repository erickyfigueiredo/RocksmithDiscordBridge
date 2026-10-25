import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export function patchClient(cpp, header) {
  const marker = '// RSBRIDGE TAP v1';
  if (cpp.includes(marker) || header.includes(marker)) throw new Error('Fonte já modificada; use uma cópia limpa.');
  function once(text, anchor, replacement) {
    if (text.split(anchor).length !== 2) throw new Error(`Âncora não é única: ${anchor}`);
    return text.replace(anchor, replacement);
  }
  header = once(header, '#include "MyUnknown.h"', '#include "MyUnknown.h"\n#define RSBRIDGE_CHILD_PLAYER 1\n#include "BridgeTap.h"\n' + marker);
  header = once(header, '\tWAVEFORMATEXTENSIBLE m_WaveFormat;', '\trsbridge::Tap m_StreamTap;\n\tWAVEFORMATEXTENSIBLE m_WaveFormat;');
  cpp = once(cpp, '\tm_UsingEventHandle = useEventCallback;',
    `${marker}\n\tif (m_AsioDevice.GetConfig().isOutput)\n\t{\n\t\tconst bool tapFloat = m_WaveFormat.Format.wFormatTag == WAVE_FORMAT_IEEE_FLOAT || m_WaveFormatIsFloat;\n\t\tconst bool tapOK = m_StreamTap.Initialize(m_WaveFormat.Format, tapFloat, m_bufferNumFrames);\n\t\trslog::info_ts() << "RSBRIDGE: " << (tapOK ? "ready" : "disabled (format or mapping unavailable)") << std::endl;\n\t}\n\n\tm_UsingEventHandle = useEventCallback;`);
  cpp = once(cpp, '\t\tfor (DWORD asioCh = 0; asioCh < m_ChannelMap.size(); ++asioCh)',
    '\t\t// Audio already has the game software volume applied. Copy it independently.\n\t\tif (m_IsStarted) m_StreamTap.Publish(m_frontBuffer.data(), m_bufferNumFrames);\n\n\t\tfor (DWORD asioCh = 0; asioCh < m_ChannelMap.size(); ++asioCh)');
  // VS 2022 removed support for treating __FUNCTION__ as a concatenable string literal.
  cpp = cpp.replace(/__FUNCTION__\s+(?=")/g, '__FUNCTION__ << ').replace(/("[^"\n]*")\s+__FUNCTION__/g, '$1 << __FUNCTION__');
  return {cpp, header};
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const root = process.argv[2];
  if (!root) throw new Error('Uso: node tools/patch.mjs PASTA_RS_ASIO');
  const client = path.join(root, 'RS_ASIO/RSAsioAudioClient.cpp');
  const header = path.join(root, 'RS_ASIO/RSAsioAudioClient.h');
  const result = patchClient(fs.readFileSync(client, 'utf8').replace(/\r\n/g, '\n'), fs.readFileSync(header, 'utf8').replace(/\r\n/g, '\n'));
  // Validate every anchor before writing any upstream source.
  fs.copyFileSync(new URL('../native/BridgeTap.h', import.meta.url), path.join(root, 'RS_ASIO/BridgeTap.h'));
  fs.copyFileSync(new URL('../native/BridgePlayer.h', import.meta.url), path.join(root, 'RS_ASIO/BridgePlayer.h'));
  fs.writeFileSync(client, result.cpp); fs.writeFileSync(header, result.header);
  // Standard dependent type spelling required by current MSVC (no change to trampoline code).
  const trampoline = path.join(root, 'RS_ASIO', 'TrampolineToMethod.h');
  const trampolineText = fs.readFileSync(trampoline, 'utf8');
  const oldTuple = 'std::tuple_element<I, function_traits<TFunc>::type_list>::type...';
  if (!trampolineText.includes(oldTuple)) throw new Error('Trampoline upstream inesperado.');
  fs.writeFileSync(trampoline, trampolineText.replace(oldTuple, 'std::tuple_element_t<I, typename function_traits<TFunc>::type_list>...'));
  // Fix the same old MSVC extension in other upstream .cpp files.
  for (const file of fs.readdirSync(path.join(root, 'RS_ASIO'))) {
    if (!file.endsWith('.cpp')) continue;
    const target = path.join(root, 'RS_ASIO', file);
    const text = fs.readFileSync(target, 'utf8');
    fs.writeFileSync(target, text.replace(/__FUNCTION__\s+(?=")/g, '__FUNCTION__ << ').replace(/("[^"\n]*")\s+__FUNCTION__/g, '$1 << __FUNCTION__'));
  }
  console.log('Tap aplicado. Saída ASIO original preservada.');
}
