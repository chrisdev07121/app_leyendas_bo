class Departamento {
  final String id;
  final String nombre;

  Departamento({
    required this.id,
    required this.nombre,
  });
}

// Lista de departamentos de Bolivia
final departamentos = [
  Departamento(id: 'cochabamba', nombre: 'Cochabamba'),
  Departamento(id: 'la_paz', nombre: 'La Paz'),
  Departamento(id: 'oruro', nombre: 'Oruro'),
  Departamento(id: 'potosi', nombre: 'Potosí'),
  Departamento(id: 'sucre', nombre: 'Sucre'),
  Departamento(id: 'tarija', nombre: 'Tarija'),
  Departamento(id: 'santa_cruz', nombre: 'Santa Cruz'),
  Departamento(id: 'beni', nombre: 'Beni'),
  Departamento(id: 'pando', nombre: 'Pando'),
];
