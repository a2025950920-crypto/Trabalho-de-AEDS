class enfermeira extends Organizar {

  PImage imagemEnfermeira;
  enfermeira(int x, int y) {
    super(x, y);
    imagemEnfermeira = loadImage("enfermeira.png");
  }

  void imprimir() {
    image(imagemEnfermeira, linha, coluna);
  }
}
