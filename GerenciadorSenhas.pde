class GerenciadorSenhas {

  private int contadorNormal;
  private int contadorPreferencial;

  GerenciadorSenhas() {
    contadorNormal = 0;
    contadorPreferencial = 0;
  }

  void atribuirSenha(Paciente p) {
    String prefixo;
    int numero;

    if (p.tipoAtendimento == 'P') {
      contadorPreferencial++;
      prefixo = "P";
      numero = contadorPreferencial;
    } else {
      contadorNormal++;
      prefixo = "N";
      numero = contadorNormal;
    }

    p.senha = prefixo + formatarNumero(numero);
  }

  private String formatarNumero(int numero) {
    String texto = "" + numero;
    while (texto.length() < 4) {
      texto = "0" + texto;
    }
    return texto;
  }

  void resetar() {
    contadorNormal = 0;
    contadorPreferencial = 0;
  }
}
