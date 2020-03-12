Map example = {
  // Project Node
  'vy_dart_meme': {
    'sourceLanguage': 'en_US',
    'targetLanguages': ['it_IT', 'pt_BR'],
    'addedLanguages': ['fr_FR'],
    'terms': {
      // id
      'hello': {
        'en_US': 'Hello',
        'id': 'hello',
        'sourcePath': 'lib/src/sample.dart',
        'description': 'Informal salutation',
        'exampleValues': [],
        'it_IT': 'Ciao',
        'pt_BR': 'Oi'
      }
    }
  }
};

List<Map<String, dynamic>> Meme = [
  {
    'name': 'project 1',
    'header': {
      'sourceLanguageTag': 'en-US',
      'originalTargetLanguageTags': ['it-IT', 'pt-BR']
    },
    'terms': {
      '0001': {
        'sourceLanguage': 'en-US',
        'id': '0001',
        'idTerms': {'en-US': 'Hello'}
      }
    }
  }
];
