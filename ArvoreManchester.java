// atributo: 0 = SatO2, 1 = Temp, 2 = Dor, 3 = Consciencia
class NoManchester {
  boolean ativo;
  boolean ehFolha;
  int atributo;
  char operador; // '=', '<', '>='
  float valorReferencia;
  char corFolha;

  NoManchester() {
    ativo = false;
  }

  static NoManchester criarTeste(int atributo, char operador, float valorReferencia) {
    NoManchester n = new NoManchester();
    n.ativo = true;
    n.ehFolha = false;
    n.atributo = atributo;
    n.operador = operador;
    n.valorReferencia = valorReferencia;
    return n;
  }

  static NoManchester criarFolha(char cor) {
    NoManchester n = new NoManchester();
    n.ativo = true;
    n.ehFolha = true;
    n.corFolha = cor;
    return n;
  }

  boolean avaliar(Paciente p) {
    float valor = p.sinaisVitais[atributo];
    switch (operador) {
      case '=':  return valor == valorReferencia;
      case '<':  return valor < valorReferencia;
      case '>=': return valor >= valorReferencia;
    }
    return false;
  }
}

// vetor com indexação de heap: filho esquerdo = 2i+1 (teste true), direito = 2i+2 (teste false)
class ArvoreManchester {

  private NoManchester[] nos;
  private static final int TAMANHO_VETOR = 31;

  ArvoreManchester() {
    nos = new NoManchester[TAMANHO_VETOR];
    for (int i = 0; i < TAMANHO_VETOR; i++) {
      nos[i] = new NoManchester();
    }
    montarArvore();
  }

  private void montarArvore() {
    nos[0]  = NoManchester.criarTeste(3, '=', 1);
    nos[1]  = NoManchester.criarFolha('V');

    nos[2]  = NoManchester.criarTeste(0, '<', 92);
    nos[5]  = NoManchester.criarFolha('L');

    nos[6]  = NoManchester.criarTeste(2, '>=', 8);
    nos[13] = NoManchester.criarFolha('A');

    nos[14] = NoManchester.criarTeste(1, '>=', 38.0f);
    nos[29] = NoManchester.criarFolha('G');
    nos[30] = NoManchester.criarFolha('B');
  }

  char classificar(Paciente p) {
    int i = 0;
    while (!nos[i].ehFolha) {
      i = nos[i].avaliar(p) ? (2 * i + 1) : (2 * i + 2);
    }
    p.corClassificacao = nos[i].corFolha;
    return nos[i].corFolha;
  }
}
