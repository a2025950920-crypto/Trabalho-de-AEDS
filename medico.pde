class medico extends Organizar {

  PImage imagemMedico;
  medico(int x, int y) {
    super(x, y);
    imagemMedico = loadImage("medico.png");
  }

  void imprimir() {
    image(imagemMedico, linha, coluna);
  }
}
