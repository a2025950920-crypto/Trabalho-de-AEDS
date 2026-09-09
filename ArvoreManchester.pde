class ArvoreManchester {
  NoManchester[] arvore;

  ArvoreManchester() {
    this.arvore = new NoManchester[31];
    montarArvore();
  }

  private void montarArvore() {
    arvore[0] = new NoManchester(3, 1.0, "==");
    arvore[1] = new NoManchester(CorManchester.VERMELHO);
    arvore[2] = new NoManchester(0, 92.0, "<");
    arvore[5] = new NoManchester(CorManchester.LARANJA);
    arvore[6] = new NoManchester(2, 8.0, ">=");
    arvore[13] = new NoManchester(CorManchester.AMARELO);
    arvore[14] = new NoManchester(1, 38.0, ">=");
    arvore[29] = new NoManchester(CorManchester.VERDE);
    arvore[30] = new NoManchester(CorManchester.AZUL);
  }

  CorManchester classificarPaciente(float[] sinaisVitais) {
    int i = 0;

    while (arvore[i] != null && !arvore[i].ehFolha) {
      NoManchester noAtual = arvore[i];
      float valorPaciente = sinaisVitais[noAtual.indiceAtributo];
      boolean testeVerdadeiro = false;

      if (noAtual.operador.equals("==")) {
        testeVerdadeiro = (valorPaciente == noAtual.valorCorte);
      } else if (noAtual.operador.equals("<")) {
        testeVerdadeiro = (valorPaciente < noAtual.valorCorte);
      } else if (noAtual.operador.equals(">=")) {
        testeVerdadeiro = (valorPaciente >= noAtual.valorCorte);
      }

      if (testeVerdadeiro) {
        i = 2 * i + 1;
      } else {
        i = 2 * i + 2;
      }
    }

    if (arvore[i] != null && arvore[i].ehFolha) {
      return arvore[i].corResultante;
    }

    return CorManchester.AZUL;
  }
}
