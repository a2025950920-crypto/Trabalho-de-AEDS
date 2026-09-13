PImage[] imagensMapas;

int contadorGlobalID = 1;
int mapaSelecionadoIndex = 0;
PImage imgTelaInicial;

final int LARGURA_JANELA = 930;
final int ALTURA_JANELA = 780;

final int MARGEM = 20;
final int ALTURA_CABECALHO = 100;
final int LARGURA_LEGENDA = 250;

char[][] mapa;
Organizar[][] celulasOrganizar;
int numLinhas;
int numColunas;

float tamanhoCelula;
float origemX;
float origemY;

String[] nomesArquivos;
int arquivoAtual = 0;
String mensagemErro = "";

color corChao, corParede, corGerador, corRemovedor, corTotem, corAssento, corEnfermeiro, corMedico, corGrade;
PImage imagem1, imagem2, imagem3, imagem4, imagem5, imagem6, imagem7, imagem8, imagem9, imagem10, imagem11, imagem12, imagem13, imagem14;

int estados = 0; 

FilaPacientes pacientesAtivos;
GerenciadorSenhas gerenciadorSenhas;
GerenciadorAtendimento gerenciadorAtendimento;
ArvoreManchester arvoreManchester;
AlgoritmoWavefront wavefront;
NavegadorAgente navegador;

Coordenada coordGerador, coordRemovedor, coordTotem, coordEnfermeira, coordMedico;

float proximoSpawnTempo = 0;
float tempoUltimaAtualizacao = 0;
float tempoAcumuladoTriagem = 0;
float tempoAcumuladoMedico = 0;
Paciente pacienteEmTriagem = null;
Paciente pacienteEmConsulta = null;

void settings() {
  size(LARGURA_JANELA, ALTURA_JANELA);
}

void setup() {
  surface.setTitle("Visualizador de Mapa Hospitalar Multiagente");
  
  imagensMapas = new PImage[2];
  imagensMapas[0] = loadImage("mapa1.png"); 
  imagensMapas[1] = loadImage("mapa2.png");
  
  imagem1  = loadImage("paciente_sem_identificacao.png");
  imagem2  = loadImage("paciente_sem_risco.png");
  imagem3  = loadImage("paciente_com_menos_risco.png");
  imagem4  = loadImage("paciente_alto_risco.png");
  imagem5  = loadImage("paciente_sem_risco_pref.png");
  imagem6  = loadImage("paciente_com_risco_pref.png");
  imagem7  = loadImage("paciente_alto_risco_pref.png");
  imagem8  = loadImage("medico.png");
  imagem9  = loadImage("enfermeira.png");
  imagem10 = loadImage("gerador_removedor.png");
  imagem11 = loadImage("tela_senhas.png");
  imagem12 = loadImage("parede.png");
  imagem13 = loadImage("chao.png");
  imagem14 = loadImage("assento.png");
  imgTelaInicial = loadImage("Tela_Inicial.jpg");

  corChao       = color(239, 229, 194);
  corParede     = color(205, 164, 112);
  corGerador    = color(20, 155, 45);
  corRemovedor  = color(225, 45, 55);
  corTotem      = color(50, 90, 225);
  corAssento    = color(115, 62, 31);
  corEnfermeiro = color(35);
  corMedico     = color(250, 205, 20);
  corGrade      = color(175, 151, 112);

  nomesArquivos = encontrarArquivos();

  if (nomesArquivos.length == 0) {
    mensagemErro = "Nenhum arquivo .txt encontrado na pasta data.";
  }
}

void draw() {
  maquinaEstados();
}

void inicializarSimulacao() {
  pacientesAtivos = new FilaPacientes();
  gerenciadorSenhas = new GerenciadorSenhas();
  gerenciadorAtendimento = new GerenciadorAtendimento();
  arvoreManchester = new ArvoreManchester();
  wavefront = new AlgoritmoWavefront();
  navegador = new NavegadorAgente();

  // Reset total dos ponteiros de atendimento
  pacienteEmTriagem = null;
  pacienteEmConsulta = null;
  tempoAcumuladoTriagem = 0;
  tempoAcumuladoMedico = 0;

  proximoSpawnTempo = millis() + (calcularProximoSpawn() * 1000);
  tempoUltimaAtualizacao = millis();
}

void carregarMapa(String arquivo) {
  mensagemErro = "";
  String[] linhas = loadStrings(arquivo);

  if (linhas == null || linhas.length == 0) {
    mensagemErro = "Não foi possível abrir o arquivo: " + arquivo;
    return;
  }

  String[] dimensoes = splitTokens(trim(linhas[0]));
  if (dimensoes.length != 2) {
    mensagemErro = "A primeira linha deve conter dois inteiros: n m.";
    return;
  }

  try {
    numLinhas = Integer.parseInt(dimensoes[0]);
    numColunas = Integer.parseInt(dimensoes[1]);
  }
  catch (Exception e) {
    mensagemErro = "As dimensões do mapa devem ser números inteiros.";
    return;
  }

  if (linhas.length != numLinhas + 1) {
    mensagemErro = "Quantidade de linhas inválida no arquivo.";
    return;
  }

  // Reset das coordenadas antes da leitura do novo arquivo
  coordGerador = null;
  coordRemovedor = null;
  coordTotem = null;
  coordEnfermeira = null;
  coordMedico = null;

  mapa = new char[numLinhas][numColunas];
  celulasOrganizar = new Organizar[numLinhas][numColunas];

  int geradores = 0;
  int removedores = 0;

  for (int i = 0; i < numLinhas; i++) {
    String linha = linhas[i + 1];
    if (linha.length() != numColunas) {
      mensagemErro = "A linha " + (i + 2) + " possui tamanho incorreto.";
      return;
    }

    for (int j = 0; j < numColunas; j++) {
      char tipo = linha.charAt(j);
      if (!tipoValido(tipo)) {
        mensagemErro = "Caractere inválido '" + tipo + "'.";
        return;
      }

      mapa[i][j] = tipo;
      definidorCelulas(tipo, i, j);

      if (tipo == 'G') {
        geradores++;
        coordGerador = new Coordenada(i, j);
      }
      if (tipo == 'R') {
        removedores++;
        coordRemovedor = new Coordenada(i, j);
      }
      if (tipo == 'T') {
        coordTotem = new Coordenada(i, j);
      }
      if (tipo == 'E') {
        coordEnfermeira = new Coordenada(i, j);
      }
      if (tipo == 'M') {
        coordMedico = new Coordenada(i, j);
      }
    }
  }

  if (geradores != 1 || removedores != 1) {
    mensagemErro = "O mapa deve ter exatamente 1 Gerador (G) e 1 Removedor (R).";
    return;
  }

  calcularGeometria();
  inicializarSimulacao();
}

boolean tipoValido(char tipo) {
  return tipo == 'G' || tipo == 'R' || tipo == 'T' || tipo == 'A' || tipo == 'E' || tipo == 'M' || tipo == '#' || tipo == '.';
}

void calcularGeometria() {
  float larguraDisponivel = width - 2 * MARGEM - LARGURA_LEGENDA;
  float alturaDisponivel = height - ALTURA_CABECALHO - 2 * MARGEM;

  tamanhoCelula = min(larguraDisponivel / numColunas, alturaDisponivel / numLinhas);
  origemX = MARGEM;
  origemY = ALTURA_CABECALHO + (alturaDisponivel - numLinhas * tamanhoCelula) / 2.0;
}

void maquinaEstados() {
  if (estados == 0) {
    menuINICIO();
  } else if (estados == 1) {
    jogo();
  } else if (estados == 2) {
    menuMEIO();
  } else if (estados == 3) {
    menuSELECAO_MAPA();
  }
}

void jogo() {
  background(245);
  desenharCabecalho();

  if (!mensagemErro.equals("")) {
    desenharErro();
    return;
  }

  desenharMapa();
  atualizarEGerenciarAgentes();
  desenharLegenda();
  desenharInformacaoCelula();
}

void atualizarEGerenciarAgentes() {
  float agora = millis();

  tentarIniciarAtendimentos();

  if (agora >= proximoSpawnTempo && coordGerador != null) {
    boolean geradorOcupado = false;
    NoFila temp = pacientesAtivos.getInicio();
    while (temp != null) {
      if (temp.paciente.linha == coordGerador.linha && temp.paciente.coluna == coordGerador.coluna) {
        geradorOcupado = true;
        break;
      }
      temp = temp.proximo;
    }

    if (!geradorOcupado) {
      Paciente novoP = new Paciente(coordGerador.linha, coordGerador.coluna);
      pacientesAtivos.enfileirar(novoP);
      proximoSpawnTempo = agora + (calcularProximoSpawn() * 1000);
    }
  }

  boolean[][] ocupadas = new boolean[numLinhas][numColunas];
  NoFila curr = pacientesAtivos.getInicio();
  while (curr != null) {
    ocupadas[curr.paciente.linha][curr.paciente.coluna] = true;
    curr = curr.proximo;
  }

  NoFila pNo = pacientesAtivos.getInicio();
  while (pNo != null) {
    Paciente p = pNo.paciente;
    Coordenada destino = obterDestinoDoPaciente(p);

    if (destino != null) {
      int distManhattan = abs(p.linha - destino.linha) + abs(p.coluna - destino.coluna);
      
      boolean estaNoDestino = (distManhattan == 0);
      if (p.estado == EstadoPaciente.EM_TRIAGEM || p.estado == EstadoPaciente.EM_CONSULTA) {
        estaNoDestino = (distManhattan <= 1);
      }

      if (!estaNoDestino) {
        int[][] dists = wavefront.calcularWavefront(destino.linha, destino.coluna, mapa);
        Coordenada prox = navegador.proximoPasso(p.linha, p.coluna, dists, ocupadas);

        if (prox != null) {
          ocupadas[p.linha][p.coluna] = false;
          p.linha = prox.linha;
          p.coluna = prox.coluna;
          ocupadas[p.linha][p.coluna] = true;
        }
      } else {
        processarChegadaAoDestino(p);
      }
    }

    float px = origemX + p.coluna * tamanhoCelula;
    float py = origemY + p.linha * tamanhoCelula;

    noStroke();
    if (p.corClassificacao == 'V') fill(255, 0, 0, 200);
    else if (p.corClassificacao == 'L') fill(255, 127, 0, 200);
    else if (p.corClassificacao == 'A') fill(255, 215, 0, 200);
    else if (p.corClassificacao == 'G') fill(50, 205, 50, 200);
    else fill(30, 144, 255, 200);

    ellipse(px + tamanhoCelula / 2, py + tamanhoCelula / 2, tamanhoCelula * 1.3, tamanhoCelula * 1.3);

    PImage img = obterSpritePaciente(p);
    image(img, px, py, tamanhoCelula, tamanhoCelula);

    pNo = pNo.proximo;
  }
}

void tentarIniciarAtendimentos() {
  if (pacienteEmTriagem == null) {
    pacienteEmTriagem = gerenciadorAtendimento.chamarProximoTriagem();
    
    if (pacienteEmTriagem == null) {
      NoFila temp = pacientesAtivos.getInicio();
      while (temp != null) {
        if (temp.paciente.estado == EstadoPaciente.AGUARDANDO_TRIAGEM) {
          pacienteEmTriagem = temp.paciente;
          break;
        }
        temp = temp.proximo;
      }
    }

    if (pacienteEmTriagem != null) {
      pacienteEmTriagem.estado = EstadoPaciente.EM_TRIAGEM;
      pacienteEmTriagem.assentoReservado = null;
    }
  }

  if (pacienteEmConsulta == null) {
    pacienteEmConsulta = gerenciadorAtendimento.chamarProximoMedico();
    
    if (pacienteEmConsulta == null) {
      NoFila temp = pacientesAtivos.getInicio();
      while (temp != null) {
        if (temp.paciente.estado == EstadoPaciente.AGUARDANDO_MEDICO) {
          pacienteEmConsulta = temp.paciente;
          break;
        }
        temp = temp.proximo;
      }
    }

    if (pacienteEmConsulta != null) {
      pacienteEmConsulta.estado = EstadoPaciente.EM_CONSULTA;
      pacienteEmConsulta.assentoReservado = null;
    }
  }
}

Coordenada obterDestinoDoPaciente(Paciente p) {
  switch (p.estado) {
  case EM_TRANSITO_TOTEM:
    return coordTotem;
  case AGUARDANDO_TRIAGEM:
  case AGUARDANDO_MEDICO:
    if (p.assentoReservado == null) {
      p.assentoReservado = buscarAssentoLivreMaisProximo(p);
    }
    return (p.assentoReservado != null) ? p.assentoReservado : new Coordenada(p.linha, p.coluna);
  case EM_TRIAGEM:
    p.assentoReservado = null;
    return coordEnfermeira;
  case EM_CONSULTA:
    p.assentoReservado = null;
    return coordMedico;
  case EM_TRANSITO_REMOVEDOR:
    p.assentoReservado = null;
    return coordRemovedor;
  default:
    return null;
  }
}

Coordenada buscarAssentoLivreMaisProximo(Paciente p) {
  int menorDist = 9999;
  Coordenada melhor = null;

  for (int i = 0; i < numLinhas; i++) {
    for (int j = 0; j < numColunas; j++) {
      if (mapa[i][j] == 'A') {
        Coordenada acesso = obterAcessoValidoAssento(i, j);
        if (acesso != null && !assentoEstaOcupadoOuReservado(acesso.linha, acesso.coluna, p)) {
          int dist = abs(p.linha - acesso.linha) + abs(p.coluna - acesso.coluna);
          if (dist < menorDist) {
            menorDist = dist;
            melhor = acesso;
          }
        }
      }
    }
  }

  return melhor;
}

Coordenada obterAcessoValidoAssento(int l, int c) {
  if (c - 1 >= 0 && mapa[l][c - 1] == '.') return new Coordenada(l, c - 1);
  if (l - 1 >= 0 && mapa[l - 1][c] == '.') return new Coordenada(l - 1, c);
  if (l + 1 < numLinhas && mapa[l + 1][c] == '.') return new Coordenada(l + 1, c);
  if (c + 1 < numColunas && mapa[l][c + 1] == '.') return new Coordenada(l, c + 1);
  
  return null;
}

boolean assentoEstaOcupadoOuReservado(int l, int c, Paciente pacienteAtual) {
  NoFila temp = pacientesAtivos.getInicio();
  
  while (temp != null) {
    Paciente outro = temp.paciente;
    
    if (outro != pacienteAtual) {
      if (outro.linha == l && outro.coluna == c) {
        return true;
      }
      
      if (outro.assentoReservado != null && outro.assentoReservado.linha == l && outro.assentoReservado.coluna == c) {
        return true;
      }
    }
    temp = temp.proximo;
  }
  
  return false;
}

void processarChegadaAoDestino(Paciente p) {
  if (p.estado == EstadoPaciente.EM_TRANSITO_TOTEM) {
    gerenciadorSenhas.atribuirSenha(p);
    gerenciadorAtendimento.enfileirarTriagem(p);
    p.estado = EstadoPaciente.AGUARDANDO_TRIAGEM;
  } 
  else if (p.estado == EstadoPaciente.EM_TRIAGEM && p == pacienteEmTriagem) {
    if (tempoAcumuladoTriagem == 0) {
      tempoAcumuladoTriagem = millis() + (calcularTempoTriagem() * 1000);
    } else if (millis() >= tempoAcumuladoTriagem) {
      CorManchester cor = arvoreManchester.classificarPaciente(p.sinaisVitais);
      if (cor == CorManchester.VERMELHO) p.corClassificacao = 'V';
      else if (cor == CorManchester.LARANJA) p.corClassificacao = 'L';
      else if (cor == CorManchester.AMARELO) p.corClassificacao = 'A';
      else if (cor == CorManchester.VERDE) p.corClassificacao = 'G';
      else p.corClassificacao = 'B';

      gerenciadorAtendimento.enfileirarMedico(p);
      p.estado = EstadoPaciente.AGUARDANDO_MEDICO;
      pacienteEmTriagem = null;
      tempoAcumuladoTriagem = 0;
    }
  } 
  else if (p.estado == EstadoPaciente.EM_CONSULTA && p == pacienteEmConsulta) {
    if (tempoAcumuladoMedico == 0) {
      tempoAcumuladoMedico = millis() + (calcularTempoConsulta() * 1000);
    } else if (millis() >= tempoAcumuladoMedico) {
      p.estado = EstadoPaciente.EM_TRANSITO_REMOVEDOR;
      pacienteEmConsulta = null;
      tempoAcumuladoMedico = 0;
    }
  } 
  else if (p.estado == EstadoPaciente.EM_TRANSITO_REMOVEDOR) {
    pacientesAtivos.removerPaciente(p);
  }
}

PImage obterSpritePaciente(Paciente p) {
  if (p.corClassificacao == 'V' || p.corClassificacao == 'L') {
    return (p.tipoAtendimento == 'P') ? imagem7 : imagem4;
  } else if (p.corClassificacao == 'A') {
    return (p.tipoAtendimento == 'P') ? imagem6 : imagem3;
  } else if (p.corClassificacao == 'G' || p.corClassificacao == 'B') {
    return (p.tipoAtendimento == 'P') ? imagem5 : imagem2;
  }
  return (p.tipoAtendimento == 'P') ? imagem5 : imagem1;
}

void desenharMapa() {
  noStroke();

  for (int i = 0; i < numLinhas; i++) {
    for (int j = 0; j < numColunas; j++) {
      char tipo = mapa[i][j];
      float x = origemX + j * tamanhoCelula;
      float y = origemY + i * tamanhoCelula;

      fill(corDaCelula(tipo));
      rect(x, y, tamanhoCelula, tamanhoCelula);

      desenharImagem(tipo, x, y);
    }
  }
}

color corDaCelula(char tipo) {
  switch (tipo) {
  case '#':
    return corParede;
  case 'G':
    return corGerador;
  case 'R':
    return corRemovedor;
  case 'T':
    return corTotem;
  case 'A':
    return corAssento;
  case 'E':
    return corEnfermeiro;
  case 'M':
    return corMedico;
  default:
    return corChao;
  }
}

void desenharImagem(char tipo, float x, float y) {
  PImage imagem = null;
  if (tipo == 'G' || tipo == 'R') imagem = imagem10;
  else if (tipo == 'A') imagem = imagem14;
  else if (tipo == 'E') imagem = imagem9;
  else if (tipo == 'M') imagem = imagem8;
  else if (tipo == '#') imagem = imagem12;
  else if (tipo == '.') imagem = imagem13;

  if (imagem != null) image(imagem, x, y, tamanhoCelula, tamanhoCelula);
}

void desenharCabecalho() {
  fill(35);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Simulador Hospitalar Multiagente", MARGEM, 16);

  textSize(14);
  fill(90);
  text("Pressione P para Pausar / Menu", MARGEM, 50);
}

void desenharLegenda() {
  float x = width - LARGURA_LEGENDA + 26;
  float y = ALTURA_CABECALHO + 20;

  fill(40);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Legenda", x, y);

  y += 35;
  itemLegenda(x, y, '.', "Chão", corChao);
  y += 32;
  itemLegenda(x, y, '#', "Parede", corParede);
  y += 32;
  itemLegenda(x, y, 'G', "Gerador", corGerador);
  y += 32;
  itemLegenda(x, y, 'R', "Removedor", corRemovedor);
  y += 32;
  itemLegenda(x, y, 'T', "Totem", corTotem);
  y += 32;
  itemLegenda(x, y, 'A', "Assento", corAssento);
  y += 32;
  itemLegenda(x, y, 'E', "Enfermeira", corEnfermeiro);
  y += 32;
  itemLegenda(x, y, 'M', "Médico", corMedico);
}

void itemLegenda(float x, float y, char simbolo, String desc, color cor) {
  stroke(80);
  fill(cor);
  rect(x, y, 22, 22);

  fill(45);
  textAlign(LEFT, CENTER);
  textSize(13);
  text(desc, x + 30, y + 10);
}

void desenharInformacaoCelula() {
  int coluna = floor((mouseX - origemX) / tamanhoCelula);
  int linha = floor((mouseY - origemY) / tamanhoCelula);

  if (linha >= 0 && linha < numLinhas && coluna >= 0 && coluna < numColunas) {
    char tipo = mapa[linha][coluna];
    fill(40);
    textAlign(LEFT, TOP);
    textSize(13);
    text("Posição: [" + linha + "][" + coluna + "] Tipo: " + tipo, MARGEM, height - 30);
  }
}

void desenharErro() {
  fill(255, 235, 235);
  stroke(190, 40, 40);
  rect(MARGEM, ALTURA_CABECALHO, width - 2 * MARGEM, 100, 8);

  fill(150, 25, 25);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Erro ao carregar o mapa:", MARGEM + 15, ALTURA_CABECALHO + 15);
  textSize(14);
  text(mensagemErro, MARGEM + 15, ALTURA_CABECALHO + 45);
}

void menuINICIO() {
  if (imgTelaInicial != null) {
    image(imgTelaInicial, 0, 0, width, height);
  } else {
    background(235, 240, 242);
  }

  noStroke();
  fill(15, 23, 42, 60);
  rect(0, 0, width, height);

  int bannerH = 55;
  int btnH = 48;
  int espacamento = 20;

  int alturaTotal = bannerH + 35 + btnH + espacamento + btnH;
  int startY = (height - alturaTotal) / 2;

  int bannerW = min(520, width - 60);
  int bannerX = (width - bannerW) / 2;
  int bannerY = startY;

  fill(45, 125, 130, 230);
  stroke(255);
  strokeWeight(2);
  rect(bannerX, bannerY, bannerW, bannerH, 12);

  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(22);
  text("SIMULADOR HOSPITALAR MULTIAGENTE", width / 2, bannerY + bannerH / 2 - 1);

  int btnW = 240;
  int btnX = (width - btnW) / 2;
  int startBtnY = bannerY + bannerH + 35;

  boolean mouseIniciar = (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= startBtnY && mouseY <= startBtnY + btnH);
  fill(mouseIniciar ? color(55, 155, 160) : color(45, 125, 130));
  stroke(255);
  strokeWeight(2);
  rect(btnX, startBtnY, btnW, btnH, 10);

  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Iniciar Simulação", width / 2, startBtnY + btnH / 2 - 1);

  int sairY = startBtnY + btnH + espacamento;
  boolean mouseSair = (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= sairY && mouseY <= sairY + btnH);
  fill(mouseSair ? color(55, 155, 160) : color(45, 125, 130));
  stroke(255);
  strokeWeight(2);
  rect(btnX, sairY, btnW, btnH, 10);

  fill(255);
  noStroke();
  text("Sair", width / 2, sairY + btnH / 2 - 1);
}

void menuSELECAO_MAPA() {
  if (imgTelaInicial != null) {
    image(imgTelaInicial, 0, 0, width, height);
  } else {
    background(235, 240, 242);
  }

  noStroke();
  fill(15, 23, 42, 60);
  rect(0, 0, width, height);

  int bannerH = 50;
  int cardH = 145;
  int btnH = 44;
  int espacamentoVertical = 20;

  int alturaTotalMenu = bannerH + espacamentoVertical + cardH + espacamentoVertical + btnH + 12 + btnH;
  int startY = (height - alturaTotalMenu) / 2;

  int bannerW = 340;
  int bannerX = (width - bannerW) / 2;
  int bannerY = startY;

  fill(45, 125, 130, 230);
  stroke(255);
  strokeWeight(2);
  rect(bannerX, bannerY, bannerW, bannerH, 12);

  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(22);
  text("Selecione o Mapa", width / 2, bannerY + bannerH / 2 - 1);

  if (nomesArquivos == null || nomesArquivos.length == 0) return;

  int cardW = 140;
  int espacamentoCard = 25;
  int totalW = (nomesArquivos.length * cardW) + ((nomesArquivos.length - 1) * espacamentoCard);
  int startX = (width - totalW) / 2;
  int cardY = bannerY + bannerH + espacamentoVertical;

  for (int i = 0; i < nomesArquivos.length; i++) {
    int x = startX + i * (cardW + espacamentoCard);
    boolean estaSelecionado = (i == mapaSelecionadoIndex);

    if (estaSelecionado) {
      stroke(255, 215, 0);
      strokeWeight(4);
      fill(30, 75, 80, 230);
    } else {
      stroke(200, 220, 225);
      strokeWeight(2);
      fill(245, 250, 252, 210);
    }
    rect(x, cardY, cardW, cardH, 14);

    int imgX = x + 10;
    int imgY = cardY + 10;
    int imgW = cardW - 20;
    int imgH = 90;

    if (imagensMapas != null && i < imagensMapas.length && imagensMapas[i] != null) {
      image(imagensMapas[i], imgX, imgY, imgW, imgH);
    } else {
      fill(200);
      noStroke();
      rect(imgX, imgY, imgW, imgH, 8);
    }

    fill(estaSelecionado ? color(255) : color(30, 50, 60));
    textAlign(CENTER, CENTER);
    textSize(13);
    text("Mapa " + (i + 1), x + cardW / 2, cardY + 122);
  }

  int btnW = 220;
  int btnX = (width - btnW) / 2;
  int startBtnY = cardY + cardH + espacamentoVertical;

  boolean mouseComecar = (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= startBtnY && mouseY <= startBtnY + btnH);
  fill(mouseComecar ? color(55, 155, 160) : color(45, 125, 130));
  stroke(255);
  strokeWeight(2);
  rect(btnX, startBtnY, btnW, btnH, 10);

  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Carregar Mapa", width / 2, startBtnY + btnH / 2 - 1);

  int voltarY = startBtnY + btnH + 12;
  boolean mouseVoltar = (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= voltarY && mouseY <= voltarY + btnH);
  fill(mouseVoltar ? color(55, 155, 160) : color(45, 125, 130));
  stroke(255);
  strokeWeight(2);
  rect(btnX, voltarY, btnW, btnH, 10);

  fill(255);
  noStroke();
  text("Voltar", width / 2, voltarY + btnH / 2 - 1);
}

void menuMEIO() {
  fill(0, 150);
  rect(0, 0, width, height);

  fill(255);
  rect(width / 2 - 150, height / 2 - 100, 300, 200, 10);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("PAUSADO", width / 2, height / 2 - 60);

  fill(200);
  rect(width / 2 - 100, height / 2 - 20, 200, 40);
  fill(0);
  textSize(14);
  text("Continuar (P)", width / 2, height / 2);

  fill(200);
  rect(width / 2 - 100, height / 2 + 30, 200, 40);
  fill(0);
  text("Menu Inicial", width / 2, height / 2 + 50);
}

String[] encontrarArquivos() {
  File pasta = new File(sketchPath("data"));
  File[] arquivos = pasta.listFiles();

  if (arquivos == null) return new String[0];

  int qtd = 0;
  for (File f : arquivos) {
    if (f.isFile() && f.getName().endsWith(".txt") && !f.getName().equals("historico_commits.txt")) {
      qtd++;
    }
  }

  String[] nomes = new String[qtd];
  int idx = 0;
  for (File f : arquivos) {
    if (f.isFile() && f.getName().endsWith(".txt") && !f.getName().equals("historico_commits.txt")) {
      nomes[idx++] = f.getName();
    }
  }
  return nomes;
}

void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (estados == 1) estados = 2;
    else if (estados == 2) estados = 1;
  }
}

void mousePressed() {
  if (estados == 0) {
    int bannerH = 55;
    int btnH = 48;
    int espacamento = 20;

    int alturaTotal = bannerH + 35 + btnH + espacamento + btnH;
    int startY = (height - alturaTotal) / 2;

    int btnW = 240;
    int btnX = (width - btnW) / 2;
    int startBtnY = startY + bannerH + 35;
    int sairY = startBtnY + btnH + espacamento;

    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= startBtnY && mouseY <= startBtnY + btnH) {
      estados = 3;
      return;
    }

    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= sairY && mouseY <= sairY + btnH) {
      exit();
      return;
    }
  } else if (estados == 3) {
    int bannerH = 50;
    int cardH = 145;
    int btnH = 44;
    int espacamentoVertical = 20;

    int alturaTotalMenu = bannerH + espacamentoVertical + cardH + espacamentoVertical + btnH + 12 + btnH;
    int startY = (height - alturaTotalMenu) / 2;

    int cardW = 140;
    int espacamentoCard = 25;
    int totalW = (nomesArquivos.length * cardW) + ((nomesArquivos.length - 1) * espacamentoCard);
    int startX = (width - totalW) / 2;
    int cardY = startY + bannerH + espacamentoVertical;

    for (int i = 0; i < nomesArquivos.length; i++) {
      int x = startX + i * (cardW + espacamentoCard);
      if (mouseX >= x && mouseX <= x + cardW && mouseY >= cardY && mouseY <= cardY + cardH) {
        mapaSelecionadoIndex = i;
        return;
      }
    }

    int btnW = 220;
    int btnX = (width - btnW) / 2;
    int startBtnY = cardY + cardH + espacamentoVertical;
    int voltarY = startBtnY + btnH + 12;

    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= startBtnY && mouseY <= startBtnY + btnH) {
      if (nomesArquivos != null && nomesArquivos.length > 0) {
        arquivoAtual = mapaSelecionadoIndex;
        carregarMapa(nomesArquivos[arquivoAtual]);
        estados = 1;
      }
      return;
    }

    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= voltarY && mouseY <= voltarY + btnH) {
      estados = 0;
      return;
    }
  } else if (estados == 2) {
    if (mouseX >= width / 2 - 100 && mouseX <= width / 2 + 100 && mouseY >= height / 2 - 20 && mouseY <= height / 2 + 20) {
      estados = 1;
    } else if (mouseX >= width / 2 - 100 && mouseX <= width / 2 + 100 && mouseY >= height / 2 + 30 && mouseY <= height / 2 + 70) {
      estados = 0;
    }
  }
}

void definidorCelulas(char tipo, int linha, int coluna) {
  celulasOrganizar[linha][coluna] = new Organizar(linha, coluna);
}
