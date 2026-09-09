class FilaCoordenadas {
  private NoCoordenada inicio, fim;
  private int tamanho = 0;

  FilaCoordenadas() {
    this.inicio = null;
    this.fim = null;
    this.tamanho = 0;
  }

  boolean vazia() {
    if (inicio == null) {
      return true;
    }
    return false;
  }

  void enfileirar(Coordenada coordenada) {
    NoCoordenada novo = new NoCoordenada(coordenada);
    if (vazia()) inicio = novo;
    else fim.proximo = novo;
    fim = novo;
    tamanho++;
  }

  Coordenada desenfileirar() {
    if (vazia() == true) {
      return null;
    }
    Coordenada valorRetorno = this.inicio.valor;
    this.inicio = this.inicio.proximo;
    if (this.inicio == null) {
      this.fim = null;
    }
    this.tamanho--;
    return valorRetorno;
  }
  
  int getTamanho() {
    return tamanho;
  }
}
