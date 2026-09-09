class NoManchester {
  int indiceAtributo;
  float valorCorte;
  String operador;
  boolean ehFolha;
  CorManchester corResultante; 

  NoManchester(int indiceAtributo, float valorCorte, String operador) {
    this.indiceAtributo = indiceAtributo;
    this.valorCorte = valorCorte;
    this.operador = operador;
    this.ehFolha = false;
    this.corResultante = null;
  }

  NoManchester(CorManchester corResultante) {
    this.ehFolha = true;
    this.corResultante = corResultante;
    this.indiceAtributo = -1;
    this.valorCorte = 0.0;
    this.operador = "";
  }
}
