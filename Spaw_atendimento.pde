float calcularProximoSpawn() {
  float lambda = 0.2;
  float u = random(0.0001, 0.9999);
  return -log(1 - u) / lambda;
}

float calcularTempoTriagem() {
  return random(2, 5);
}

float calcularTempoConsulta() {
  return random(5, 10);
}
