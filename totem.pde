class totem extends Organizar {

  private boolean ocupado;

  totem(int x, int y) {
    super(x, y);
    ocupado = false;
  }

  boolean estaLivre() {
    return !ocupado;
  }

  boolean iniciarInteracao() {
    if (ocupado) return false;
    ocupado = true;
    return true;
  }

  void finalizarInteracao() {
    ocupado = false;
  }

  void algumaFuncao() {
    println("Sou totem!");
  }
}
