import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/services/voice_command_service.dart';

void main() {
  test('English commands', () {
    expect(parseVoiceCommand('Next'), VoiceCommand.next);
    expect(parseVoiceCommand('go back please'), VoiceCommand.back);
    expect(parseVoiceCommand('say that again'), VoiceCommand.repeat);
    expect(parseVoiceCommand('Repeat.'), VoiceCommand.repeat);
  });

  test('Arabic commands with spelling variants', () {
    expect(parseVoiceCommand('التالي'), VoiceCommand.next);
    expect(parseVoiceCommand('الخطوة التالية'), VoiceCommand.next);
    expect(parseVoiceCommand('السابق'), VoiceCommand.back);
    expect(parseVoiceCommand('رجوع'), VoiceCommand.back);
    expect(parseVoiceCommand('كرر'), VoiceCommand.repeat);
    expect(parseVoiceCommand('أعد'), VoiceCommand.repeat);
    expect(parseVoiceCommand('إعادة'), VoiceCommand.repeat);
  });

  test('the last command spoken wins', () {
    expect(parseVoiceCommand('next, no, go back'), VoiceCommand.back);
  });

  test('words that merely contain a command are ignored', () {
    expect(parseVoiceCommand('ساعدني'), isNull);
    expect(parseVoiceCommand('backpack'), isNull);
    expect(parseVoiceCommand(''), isNull);
  });
}
