class GerenciadorAtendimento {

  FilaPacientes filaTriagemNormal;
  FilaPacientes filaTriagemPreferencial;
  private int consecutivasPreferencial;

  FilaPacientes filaVermelha;
  FilaPacientes filaLaranja;
  FilaPacientes filaAmarela;
  FilaPacientes filaVerde;
  FilaPacientes filaAzul;

  GerenciadorAtendimento() {
    filaTriagemNormal = new FilaPacientes();
    filaTriagemPreferencial = new FilaPacientes();
    consecutivasPreferencial = 0;

    filaVermelha = new FilaPacientes();
    filaLaranja = new FilaPacientes();
    filaAmarela = new FilaPacientes();
    filaVerde = new FilaPacientes();
    filaAzul = new FilaPacientes();
  }

  void enfileirarTriagem(Paciente p) {
    if (p.tipoAtendimento == 'P') {
      filaTriagemPreferencial.enfileirar(p);
    } else {
      filaTriagemNormal.enfileirar(p);
    }
    p.estado = EstadoPaciente.AGUARDANDO_TRIAGEM;
  }

  // no maximo 2 preferenciais seguidos para cada 1 normal
  Paciente chamarProximoTriagem() {
    boolean temPref = !filaTriagemPreferencial.estaVazia();
    boolean temNorm = !filaTriagemNormal.estaVazia();

    if (!temPref && !temNorm) return null;

    if (temPref && !temNorm) {
      consecutivasPreferencial++;
      return filaTriagemPreferencial.desenfileirar();
    }

    if (!temPref && temNorm) {
      consecutivasPreferencial = 0;
      return filaTriagemNormal.desenfileirar();
    }

    if (consecutivasPreferencial < 2) {
      consecutivasPreferencial++;
      return filaTriagemPreferencial.desenfileirar();
    } else {
      consecutivasPreferencial = 0;
      return filaTriagemNormal.desenfileirar();
    }
  }

  void enfileirarMedico(Paciente p) {
    switch (p.corClassificacao) {
      case 'V': filaVermelha.enfileirar(p); break;
      case 'L': filaLaranja.enfileirar(p);  break;
      case 'A': filaAmarela.enfileirar(p);  break;
      case 'G': filaVerde.enfileirar(p);    break;
      case 'B': filaAzul.enfileirar(p);     break;
    }
    p.estado = EstadoPaciente.AGUARDANDO_MEDICO;
  }

  // prioridade absoluta: vermelha > laranja > amarela > verde > azul, FIFO dentro da cor
  Paciente chamarProximoMedico() {
    if (!filaVermelha.estaVazia()) return filaVermelha.desenfileirar();
    if (!filaLaranja.estaVazia())  return filaLaranja.desenfileirar();
    if (!filaAmarela.estaVazia())  return filaAmarela.desenfileirar();
    if (!filaVerde.estaVazia())    return filaVerde.desenfileirar();
    if (!filaAzul.estaVazia())     return filaAzul.desenfileirar();

    return null;
  }
}
