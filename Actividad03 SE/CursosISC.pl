/*******************************************************************************
  SISTEMA EXPERTO DE GESTIÓN ACADÉMICA - ISC (UNACAR)
  Materia: Programacion Avanzada
  Nombre: Christian Omar Ceballos Hernandez
  
  Este programa modela una base de conocimiento académica avanzada para:
  - Validar la seriación de materias.
  - Controlar límites de carga según rendimiento y materias reprobadas.
  - Administrar el historial de intentos, promedios y alertas de baja.
  - Identificar alumnos de alto rendimiento y cuantificar aspirantes a cursos.
*******************************************************************************/

:- discontiguous materia/5, prerrequisito/2, historial/4.

% ==============================================================================
% 1. BASE DE CONOCIMIENTO: OFERTA ACADÉMICA (MATERIAS Y ÁREAS)
% ==============================================================================
% materia(IdMateria, NombreImprimible, Semestre, Creditos, Area).
materia(programacion1,     'Programación 1',       1, 4, programacion).
materia(matematicas1,      'Matemáticas 1',        1, 5, ciencias_basicas).
materia(base_datos,        'Base de Datos',        1, 4, programacion).

materia(programacion2,     'Programación 2',       2, 4, programacion).
materia(matematicas2,      'Matemáticas 2',        2, 5, ciencias_basicas).
materia(estructuras_datos, 'Estructuras de Datos', 2, 5, programacion).

% SERIACIÓN: prerrequisito(Materia, MateriaQueRequiere).
prerrequisito(programacion2,     programacion1).
prerrequisito(matematicas2,      matematicas1).
prerrequisito(estructuras_datos, programacion2).

% ==============================================================================
% 2. BASE DE CONOCIMIENTO: ALUMNOS E HISTORIAL HISTÓRICO DE INTENTOS
% ==============================================================================
% alumno(IdAlumno, Nombre, SemestreActual).
alumno(juan,   'Juan Perez',    2).
alumno(maria,  'Maria Garcia',  1).
alumno(carlos, 'Carlos Lopez',  2).
alumno(ana,    'Ana Martinez',  2).

% historial(IdAlumno, IdMateria, NumIntento, Calificacion).
% Permite mapear múltiples intentos de una misma materia para un alumno.
historial(juan, programacion1, 1, 85).
historial(juan, matematicas1,  1, 78).
historial(juan, base_datos,    1, 90).

historial(maria, programacion1, 1, 88).

historial(carlos, programacion1, 1, 92).
historial(carlos, programacion2, 1, 85).
historial(carlos, matematicas1,  1, 79).
historial(carlos, matematicas2,  1, 81).

% Caso Ana: Lleva 3 intentos reprobando matemáticas1 (Alerta de Baja)
historial(ana, programacion1, 1, 76).
historial(ana, base_datos,    1, 80).
historial(ana, matematicas1,  1, 50).
historial(ana, matematicas1,  2, 62).
historial(ana, matematicas1,  3, 58).

% ==============================================================================
% 3. REGLAS AUXILIARES Y LÓGICA DE APROBACIÓN
% ==============================================================================

% Una materia está aprobada si en SU ÚLTIMO INTENTO o en alguno previo sacó >= 70.
materia_aprobada(Alumno, Materia) :-
    historial(Alumno, Materia, _, Calificacion),
    Calificacion >= 70.

% Cuenta cuántas materias ha reprobado un alumno y mantiene en ese estado actualmente.
% Se considera "actualmente reprobada" si el alumno la cursó pero NO la ha aprobado.
materia_actualmente_reprobada(Alumno, Materia) :-
    historial(Alumno, Materia, _, _),
    \+ materia_aprobada(Alumno, Materia).

% Calcula el número total de materias que el alumno tiene reprobadas vigentes.
total_reprobadas(Alumno, Total) :-
    findall(M, distinct(M, materia_actualmente_reprobada(Alumno, M)), Lista),
    length(Lista, Total).

% Promedio general del alumno considerando la calificación más alta de cada materia.
promedio_general(Alumno, Promedio) :-
    alumno(Alumno, _, _),
    findall(MaxCal, (
        distinct(M, historial(Alumno, M, _, _)),
        findall(C, historial(Alumno, M, _, C), Calificaciones),
        max_list(Calificaciones, MaxCal)
    ), ListaMaximas),
    length(ListaMaximas, TotalMaterias),
    ( TotalMaterias > 0 ->
        sum_list(ListaMaximas, Suma),
        Promedio is Suma / TotalMaterias
    ;   Promedio is 0
    ).

% ==============================================================================
% 4. REGLAS DEL SISTEMA EXPERTO (REQUISITOS DE LA TAREA)
% ==============================================================================

% REQUISITO 1: Respetar Seriación
cumple_seriacion(Alumno, Materia) :-
    forall(prerrequisito(Materia, Prerreq), materia_aprobada(Alumno, Prerreq)).

% REQUISITO 2: Restricción de carga (Máx 4 materias si promedio < 80 o reprobadas > 1)
limite_carga_materias(Alumno, Limite) :-
    promedio_general(Alumno, Promedio),
    total_reprobadas(Alumno, Reprobadas),
    ( (Promedio < 80 ; Reprobadas > 1) ->
        Limite = 4
    ;   Limite = 6  % Carga normal estándar de la universidad
    ).

% REQUISITO 3: Historial de cursos y conteo de veces cursada
veces_cursada(Alumno, Materia, Veces, Calificaciones) :-
    materia(Materia, _, _, _, _),
    findall(C, historial(Alumno, Materia, _, C), Calificaciones),
    length(Calificaciones, Veces).

% REQUISITO 4: Identificar si el alumno debe ser dado de baja (3 reprobadas en una materia)
debe_ser_dado_de_baja(Alumno, Materia) :-
    veces_cursada(Alumno, Materia, Veces, _),
    Veces >= 3,
    \+ materia_aprobada(Alumno, Materia).

% REQUISITO 5: Encontrar alumnos de alto rendimiento (Promedio >= 90)
alumno_alto_rendimiento(Alumno, Promedio) :-
    alumno(Alumno, _, _),
    promedio_general(Alumno, Promedio),
    Promedio >= 90.

% REQUISITO 6: Mostrar materias por Semestre y por Área (Formateado para Consola)
materias_por_semestre(Semestre, MateriaNombre) :-
    materia(_, MateriaNombre, Semestre, _, _).

materias_por_area(Area, MateriaNombre) :-
    materia(_, MateriaNombre, _, _, Area).

% IMPRESIÓN MASIVA: Muestra TODAS las materias que pertenecen a un semestre específico
mostrar_por_semestre(Semestre) :-
    format('=== MATERIAS DEL SEMESTRE ~w ===~n', [Semestre]),
    forall(materia(_, Nombre, Semestre, Creditos, Area),
           format('- ~w (~w créditos) | Área: ~w~n', [Nombre, Creditos, Area])).

% IMPRESIÓN MASIVA: Muestra TODAS las materias que pertenecen a un área específica
mostrar_por_area(Area) :-
    format('=== MATERIAS DEL ÁREA: ~w ===~n', [Area]),
    forall(materia(_, Nombre, Semestre, Creditos, Area),
           format('- ~w (Semestre: ~w) | ~w créditos~n', [Nombre, Semestre, Creditos])).

% REQUISITO 7: Contar posibles aspirantes para abrir un curso particular
% Un alumno es aspirante si: no la ha aprobado, cumple la seriación y no está dado de baja.
es_aspirante(Alumno, Materia) :-
    alumno(Alumno, _, _),
    materia(Materia, _, _, _, _),
    \+ materia_aprobada(Alumno, Materia),
    cumple_seriacion(Alumno, Materia),
    \+ debe_ser_dado_de_baja(Alumno, _).

cantidad_aspirantes(Materia, Cantidad) :-
    materia(Materia, _, _, _, _),
    findall(A, es_aspirante(A, Materia), ListaAspirantes),
    length(ListaAspirantes, Cantidad).

% EVALUACIÓN GENERAL COMÚN: ¿Puede inscribir la materia hoy?
puede_inscribir(Alumno, Materia) :-
    alumno(Alumno, _, _),
    materia(Materia, _, _, _, _),
    \+ materia_aprobada(Alumno, Materia),
    \+ debe_ser_dado_de_baja(Alumno, _),
    cumple_seriacion(Alumno, Materia).