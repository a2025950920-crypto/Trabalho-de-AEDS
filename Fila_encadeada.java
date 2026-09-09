class NoFila {
  Paciente paciente;
  NoFila proximo;

  NoFila(Paciente p) {
    paciente = p;
    proximo = null;
  }
}

class FilaPacientes {
  private NoFila inicio;
  private NoFila fim;
  private int tamanho;

  FilaPacientes() {
    inicio = null;
    fim = null;
    tamanho = 0;
  }

  void enfileirar(Paciente p) {
    NoFila novo = new NoFila(p);
    if (estaVazia()) {
      inicio = novo;
    } else {
      fim.proximo = novo;
    }
    fim = novo;
    tamanho++;
  }

  Paciente desenfileirar() {
    if (estaVazia()) return null;
    Paciente p = inicio.paciente;
    inicio = inicio.proximo;
    if (inicio == null) fim = null;
    tamanho--;
    return p;
  }

  boolean estaVazia() {
    return inicio == null;
  }

  int getTamanho() {
    return tamanho;
  }
}
