enum ServiceCategory {
  dj('Música / DJ'),
  banquet('Banquetes / Catering'),
  furniture('Alquiler de Mobiliario'),
  venue('Salones / Espacios'),
  decoration('Decoración'),
  photography('Fotografía y Video'),
  entertainment('Entretenimiento'),
  equipment('Alquiler de Equipo');

  final String label;
  const ServiceCategory(this.label);
}
