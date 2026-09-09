enum EstadoPaciente {
  EM_TRANSITO_TOTEM,
  AGUARDANDO_TRIAGEM,
  EM_TRIAGEM,
  AGUARDANDO_MEDICO,
  EM_CONSULTA,
  EM_TRANSITO_REMOVEDOR
}

class Paciente extends Organizar {
  private static int contadorGlobalID = 0;

  int id;
  char tipoAtendimento; // 'P' ou 'N'
  String senha;
  EstadoPaciente estado;
  char corClassificacao; // V, L, A, G, B
  PImage imagemPaciente;


  // [0] SatO2 (70-100) | [1] Temp (34-42) | [2] Dor (0-10) | [3] Consciencia (0/1)
  float[] sinaisVitais;

  Paciente(int x, int y) {
    super(x, y);
    id = ++contadorGlobalID;
    estado = EstadoPaciente.EM_TRANSITO_TOTEM;
    corClassificacao = ' ';

    tipoAtendimento = (random(1.0f) < 0.25f) ? 'P' : 'N';

    sinaisVitais = new float[4];
    sinaisVitais[0] = floor(random(70, 101));
    sinaisVitais[1] = random(34.0f, 42.0f);
    sinaisVitais[2] = floor(random(0, 11));
    sinaisVitais[3] = (random(1.0f) < 0.15f) ? 1 : 0;
    imagemPaciente = loadImage("paciente sem identificação.png");

  }
}
