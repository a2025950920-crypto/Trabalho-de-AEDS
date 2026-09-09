class assento extends Organizar {

  static final int LIVRE = 0;
  static final int RESERVADO = 1;
  static final int OCUPADO = 2;

  int estado;

  assento(int x, int y) {
    super(x, y);
    estado = LIVRE;
  }

  boolean estaLivre() {
    return estado == LIVRE;
  }

  boolean reservar() {
    if (estado == LIVRE) {
      estado = RESERVADO;
      return true;
    }
    return false;
  }

  void ocupar() {
    estado = OCUPADO;
  }

  void liberar() {
    estado = LIVRE;
  }

  void algumaFuncao() {
    println("Sou assento!");
  }
}
