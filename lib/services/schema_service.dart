abstract class SchemaService {
  Object buildFormulaSchema(String formula);
  List<String> removeSameSchema(List<String> formulaList);
  int matchFormula(String formula, List<String> formulaList);
  int matchSingleFormula(String formula1, String formula2);
}
