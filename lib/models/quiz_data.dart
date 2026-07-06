class QuizPregunta {
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrectaIndex;
  final String explicacion;

  const QuizPregunta({
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrectaIndex,
    required this.explicacion,
  });
}

final Map<String, List<QuizPregunta>> quizPorLeyenda = {
  '1': [
    QuizPregunta(
      pregunta: '¿Qué extrae el Kari Kari de sus víctimas para sus rituales oscuros?',
      opciones: ['Su alma', 'Su grasa corporal', 'Su sangre', 'Su voz'],
      respuestaCorrectaIndex: 1,
      explicacion: 'El Kari Kari adormece a sus víctimas y extrae su grasa corporal, dejándolas debilitadas y con una fiebre letal.',
    ),
    QuizPregunta(
      pregunta: '¿Quién es el único curandero tradicional capaz de salvar a una víctima del Kari Kari?',
      opciones: ['Un Yatiri', 'Un médico cirujano', 'Un sacerdote', 'Un boticario'],
      respuestaCorrectaIndex: 0,
      explicacion: 'Solo un Yatiri, curandero tradicional experto del altiplano, puede diagnosticar y curar el mal causado por el Kari Kari.',
    ),
  ],
  '2': [
    QuizPregunta(
      pregunta: '¿Por qué mató el cacique al enamorado de su hija?',
      opciones: ['Por robarle oro', 'Por pertenecer a una tribu enemiga', 'Por desafiarlo a un duelo', 'Por cobardía'],
      respuestaCorrectaIndex: 1,
      explicacion: 'La joven se enamoró de un guerrero enemigo, lo cual estaba estrictamente prohibido por el cacique.',
    ),
    QuizPregunta(
      pregunta: '¿En qué fue convertida la hija del cacique para aliviar su inmenso dolor?',
      opciones: ['En una serpiente', 'En una flor del bosque', 'En una cascada', 'En un ave nocturna'],
      respuestaCorrectaIndex: 3,
      explicacion: 'Un chamán la transformó en el ave Guajojó para evitar que muriera de tristeza, cantando eternamente su lamento.',
    ),
  ],
  '3': [
    QuizPregunta(
      pregunta: '¿Cómo se llama el ritual que realizan los mineros los viernes para agradar al Tío?',
      opciones: ['La Challa', 'El Tinku', 'La K\'oa', 'El Inti Raymi'],
      respuestaCorrectaIndex: 0,
      explicacion: 'La Challa consiste en ofrecerle hojas de coca, cigarros encendidos y alcohol puro para que mantenga las minas seguras.',
    ),
    QuizPregunta(
      pregunta: '¿Qué representa principalmente la deidad de El Tío?',
      opciones: ['El dios de la lluvia', 'El protector de los animales', 'El dios del inframundo mineral y guardián de la mina', 'Un demonio que roba almas'],
      respuestaCorrectaIndex: 2,
      explicacion: 'El Tío es la deidad sincrética que rige sobre el mineral y la seguridad física de los mineros en las profundidades.',
    ),
  ],
  '4': [
    QuizPregunta(
      pregunta: '¿Qué significa que el silbido de El Silbaco se escuche muy suave y distante?',
      opciones: ['Que está muy lejos de ti', 'Que está parado exactamente a tus espaldas', 'Que ha perdido su poder', 'Que está durmiendo'],
      respuestaCorrectaIndex: 1,
      explicacion: 'La acústica engañosa del Silbaco hace que cuando silba suavemente, en realidad está acechándote de espaldas.',
    ),
    QuizPregunta(
      pregunta: '¿Cuál es el origen de El Silbaco según la creencia popular?',
      opciones: ['El alma en pena de un hombre malvado', 'Un duende del bosque', 'Un ave exótica', 'Un hechicero de la tribu'],
      respuestaCorrectaIndex: 0,
      explicacion: 'Es considerado el alma errante de un hombre malo que murió a manos de las fieras o el rigor de la selva.',
    ),
  ],
  '5': [
    QuizPregunta(
      pregunta: '¿A qué santa patrona era profundamente devoto El Chiru Chiru?',
      opciones: ['A la Virgen de Copacabana', 'A la Virgen de Urkupiña', 'A la Virgen del Socavón', 'A la Virgen de Cotoca'],
      respuestaCorrectaIndex: 2,
      explicacion: 'El Chiru Chiru oraba y era fiel devoto de la Virgen del Socavón en Oruro, a cuyos pies fue encontrado su cuerpo.',
    ),
    QuizPregunta(
      pregunta: '¿Cuál era el comportamiento característico de El Chiru Chiru al robar?',
      opciones: ['Robaba a los ricos para repartir a los pobres', 'Robaba iglesias y templos', 'Atesoraba todo para sí mismo', 'Robaba caballos de guerra'],
      respuestaCorrectaIndex: 0,
      explicacion: 'Actuaba como un protector andino, robando a mineros y comerciantes ricos para dejar comida y ropa a viudas e inválidos.',
    ),
  ],
  '6': [
    QuizPregunta(
      pregunta: '¿A qué personas suele aparecérseles La Viuda Negra en Cochabamba?',
      opciones: ['A niños traviesos', 'A hombres parranderos, trasnochadores o infieles', 'A mujeres solitarias', 'A los viajeros de día'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Aparece a altas horas ante hombres ebrios o infieles para castigar sus malas andanzas atrayéndolos a barrancos.',
    ),
    QuizPregunta(
      pregunta: '¿Qué horrible secreto revela La Viuda al quitarse el velo?',
      opciones: ['Que no tiene cabeza', 'Una calavera descarnada con cuencas ardientes', 'El rostro de un demonio con cuernos', 'El rostro de la esposa de la víctima'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Su rostro de luto desaparece para revelar una espeluznante calavera de fuego que provoca la locura o muerte por infarto.',
    ),
  ],
  '7': [
    QuizPregunta(
      pregunta: '¿De qué está construido el macabro Carretón de la Otra Vida?',
      opciones: ['De madera de siringa', 'De oro de la colonia', 'De Huesos, cráneos y fémures humanos', 'De metal forjado en el inframundo'],
      respuestaCorrectaIndex: 2,
      explicacion: 'La estructura y ruedas de esta aparición fantasmal están formadas por osamentas y cráneos humanos que crujen al rodar.',
    ),
    QuizPregunta(
      pregunta: '¿A qué hora de la madrugada se escucha pasar al Carretón?',
      opciones: ['A la medianoche', 'A las 3:00 AM (la hora muerta)', 'A las 5:00 AM', 'A las 9:00 PM'],
      respuestaCorrectaIndex: 1,
      explicacion: 'El Carretón recorre las calles arenosas del oriente a las tres de la mañana para recoger almas pecadoras.',
    ),
  ],
  '8': [
    QuizPregunta(
      pregunta: '¿Qué instrumento musical toca El Duende de Tarija en las higueras?',
      opciones: ['Una quena', 'Una guitarra pequeña o charango', 'Un violín de la zona', 'Un bombo tarijeño'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Usa una pequeña guitarra para entonar dulces melodías folclóricas e hipnotizar a las jóvenes hermosas.',
    ),
    QuizPregunta(
      pregunta: '¿Cuál es el punto débil o fobia de El Duende que permite ahuyentarlo?',
      opciones: ['Le molesta el desorden y la suciedad', 'Le teme al agua de los ríos', 'Huye si ve un perro negro', 'Se asusta con el humo del tabaco'],
      respuestaCorrectaIndex: 0,
      explicacion: 'Es un ser sumamente pulcro y remilgado, por lo que desordenar cosas o cometer actos sucios lo ahuyenta de inmediato.',
    ),
  ],
  '9': [
    QuizPregunta(
      pregunta: '¿Qué ser mitológico es considerado el guardián de las aguas dulces en el oriente boliviano?',
      opciones: ['El Mapinguari', 'El Jichi', 'El Silbaco', 'El Tío'],
      respuestaCorrectaIndex: 1,
      explicacion: 'El Jichi es una bestia mítica que habita lagunas y curichis, protegiendo las reservas de agua contra el mal uso.',
    ),
    QuizPregunta(
      pregunta: '¿Qué sucede si los humanos contaminan o abusan del agua donde vive el Jichi?',
      opciones: ['El Jichi provoca inundaciones', 'El Jichi se marcha y la laguna se seca por completo', 'El Jichi ataca el ganado', 'El Jichi canta lamentos'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Al marcharse el Jichi ofendido por la codicia o contaminación humana, el cuerpo de agua desaparece convirtiéndose en arenal.',
    ),
  ],
  '10': [
    QuizPregunta(
      pregunta: '¿Con qué elemento del cuerpo de su difunta amada fabricó el clérigo su flauta en el Manchay Puito?',
      opciones: ['Con sus cabellos dorados', 'Con un hueso de la tibia', 'Con su clavícula', 'Con madera de su ataúd'],
      respuestaCorrectaIndex: 1,
      explicacion: 'El clérigo enloquecido por la pérdida desenterró su cuerpo y talló una flauta trágica a partir de su tibia.',
    ),
    QuizPregunta(
      pregunta: '¿Qué efecto letal tenía escuchar la música del Manchay Puito?',
      opciones: ['Provocaba ceguera', 'Daba ataques de risa incontrolable', 'Infundía una depresión extrema que incitaba al suicidio', 'Causaba fiebres letales'],
      respuestaCorrectaIndex: 2,
      explicacion: 'Los trágicos tonos de la flauta amplificada en un cántaro sumían a quienes los oían en una melancolía que les hacía quitarse la vida.',
    ),
  ],
  '11': [
    QuizPregunta(
      pregunta: '¿Qué eran en realidad los gatos negros de la casona colonial de Sucre?',
      opciones: ['Duendes transformados', 'Un cónclave de brujas de la antigüedad', 'Fantasmas de soldados', 'Mascotas de los españoles'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Eran brujas que pactaron con la oscuridad para adoptar la forma de silenciosos felinos centinelas.',
    ),
    QuizPregunta(
      pregunta: '¿Qué tesoro ocultaban los gatos negros en el aljibe?',
      opciones: ['La espada del libertador', 'Un gran cargamento de oro español', 'El elixir de la eterna juventud', 'Un mapa secreto del altiplano'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Custodiaban celosamente un inmenso tesoro de monedas y lingotes de oro de la época colonial española.',
    ),
  ],
  '12': [
    QuizPregunta(
      pregunta: '¿Cómo mantenía el Jukumari a la pastora cautiva en su cueva?',
      opciones: ['La encadenaba', 'Cerraba la entrada con una enorme roca que solo él podía mover', 'La dormía con un polvo mágico', 'La custodiaba con halcones'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Colocaba una inmensa piedra en la boca de la cueva para mantenerla a salvo y evitar que regresara a su pueblo.',
    ),
    QuizPregunta(
      pregunta: '¿Qué ser legendario nació de la pastora y el Jukumari?',
      opciones: ['El Cóndor andino', 'El zorro Antonio', 'Un niño con pelaje negro y fuerza sobrehumana (Juan del Oso)', 'Un gigante de piedra'],
      respuestaCorrectaIndex: 2,
      explicacion: 'Nació un héroe con pelaje y fuerza colosal de oso, quien finalmente logró empujar la roca y liberar a su madre.',
    ),
  ],
  '13': [
    QuizPregunta(
      pregunta: '¿Qué significa "Chuchini" en la mitología amazónica del Beni?',
      opciones: ['Tierra de lagos', 'Morada del Tigre (Jaguar)', 'Loma de oro', 'Río de serpientes'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Chuchini traduce "Cueva del Jaguar" o "Morada del Tigre" en el dialecto regional de Moxos.',
    ),
    QuizPregunta(
      pregunta: '¿Quiénes se cree que construyeron las lomas artificiales de Chuchini según la leyenda?',
      opciones: ['Seres míticos mitad humanos y mitad jaguares', 'Los colonizadores españoles', 'Alienígenas ancestrales', 'Buscadores de tesoros'],
      respuestaCorrectaIndex: 0,
      explicacion: 'La tradición oral asocia las elevaciones con seres primigenios híbridos de jaguar dotados de magia.',
    ),
  ],
  '14': [
    QuizPregunta(
      pregunta: '¿Qué atuendo llevaba el Cóndor transformado en hombre para enamorar a la cholita?',
      opciones: ['Ropa de pastor colorida', 'Traje negro de bayeta con sombrero oscuro y chalina blanca', 'La armadura de un conquistador', 'Un poncho de vicuña rojo'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Simuló su pelaje y collarín blanco vistiendo un elegante traje negro con chalina blanca fina.',
    ),
    QuizPregunta(
      pregunta: '¿Qué transformación sufrió la cholita tras vivir en el nido de la cumbre?',
      opciones: ['Se convirtió en una sirena de lago', 'Le brotaron plumas negras y se transformó en cóndor', 'Se volvió invisible ante la luz solar', 'Se transformó en una vicuña'],
      respuestaCorrectaIndex: 1,
      explicacion: 'La adaptación al aire helado y la magia del Mallku hicieron que le crecieran plumas, alzando el vuelo como ave.',
    ),
  ],
  '15': [
    QuizPregunta(
      pregunta: '¿Cómo se describe físicamente al temido Mapinguari de la selva de Pando?',
      opciones: ['Un ciervo dorado de tres cuernos', 'Un humanoide gigante con un solo ojo y boca vertical en el abdomen', 'Un reptil alado gigante', 'Una pantera con cola de escorpión'],
      respuestaCorrectaIndex: 1,
      explicacion: 'Es un cíclope gigante cubierto de pelo rojo con una enorme boca dentada vertical ubicada en su vientre.',
    ),
    QuizPregunta(
      pregunta: '¿Cuál es el único punto débil por el cual se puede derrotar al Mapinguari?',
      opciones: ['El centro del ombligo', 'Su gran ojo rojo', 'Su pie izquierdo', 'La base de su cuello'],
      respuestaCorrectaIndex: 0,
      explicacion: 'La gruesa piel del Mapinguari es invulnerable a las balas, siendo su ombligo el único punto vulnerable para dardos.',
    ),
  ],
};

final Map<String, String> amuletosPorLeyenda = {
  '1': 'Escudo del Yatiri 🛡️',
  '2': 'Pluma del Guajojó 🪶',
  '3': 'Ofrenda de El Tío 👹',
  '4': 'Silbato Contra-Ecos 🌬️',
  '5': 'Medalla del Chiru Chiru 🗡️',
  '6': 'Velo de la Viuda 🕸️',
  '7': 'Hueso del Carretón 💀',
  '8': 'Charango de El Duende 🎸',
  '9': 'Escama del Jichi 🐍',
  '10': 'Flauta de Manchay Puito 🏺',
  '11': 'Ojo de Gato Negro 🐈‍⬛',
  '12': 'Garra de Jukumari 🐻',
  '13': 'Amuleto del Jaguar 🐆',
  '14': 'Pluma de Mallku 🦅',
  '15': 'Fetiche de Mapinguari 👁️',
};
