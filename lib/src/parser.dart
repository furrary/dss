String parseSimpleRule(String selector, List<String> declarations) =>
    '$selector${parseDeclarationsBlock(declarations)}';

Iterable<String> parseMediaRules(
        String selector, Map<String, List<String>> mediaRules) =>
    mediaRules.entries.map((entry) =>
        '@media ${entry.key}{$selector${parseDeclarationsBlock(entry.value)}}');

String parseDeclarationsBlock(List<String> declarations) =>
    '{' + declarations.join(';') + '}';

Iterable<String> mapToIterable(Map<String, String> declarations) =>
    declarations.entries.map((entry) => '${entry.key}:${entry.value}');

Iterable<String> fallbackToIterable(Map<String, List<String>> fallback) =>
    fallback.entries
        .map((entry) =>
            entry.value.reversed.map((String value) => '${entry.key}:$value'))
        .expand((declarationsList) => declarationsList);
