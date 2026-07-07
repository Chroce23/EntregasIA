:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).

% ==============================================================================
% 1. BASE DE CONOCIMIENTOS (10 Desarrolladores y 10 Proyectos)
% ==============================================================================

% desarrollador(Id, Nombre, Nivel).
desarrollador(d1,  'Juan Perez',     junior).
desarrollador(d2,  'Maria Garcia',   junior).
desarrollador(d3,  'Carlos Lopez',   junior).
desarrollador(d4,  'Ana Martinez',   junior).
desarrollador(d5,  'Luis Rodriguez', avanzado).
desarrollador(d6,  'Sofia Flores',   avanzado).
desarrollador(d7,  'Diego Torres',   avanzado).
desarrollador(d8,  'Laura Ruiz',     senior).
desarrollador(d9,  'Pedro Gomez',    senior).
desarrollador(d10, 'Elena Cruz',     senior).

% proyecto(Id, Nombre, Complejidad).
proyecto(pA, 'Proyecto A', bajo).
proyecto(pB, 'Proyecto B', bajo).
proyecto(pC, 'Proyecto C', medio).
proyecto(pD, 'Proyecto D', medio).
proyecto(pE, 'Proyecto E', alto).
proyecto(pF, 'Proyecto F', alto).
proyecto(pG, 'Proyecto G', muy_alto).
proyecto(pH, 'Proyecto H', bajo).
proyecto(pI, 'Proyecto I', medio).
proyecto(pJ, 'Proyecto J', muy_alto).

% ==============================================================================
% 2. REGLAS LÓGICAS DEL SISTEMA EXPERTO
% ==============================================================================

% Requerimientos de perfiles por nivel de complejidad
requiere_personal(bajo, [avanzado, junior]).
requiere_personal(medio, [senior, avanzado]).
requiere_personal(alto, [senior, avanzado, junior]).
requiere_personal(muy_alto, [senior, avanzado, avanzado, junior, junior]).

% Cuenta cuántos desarrolladores totales existen de un nivel específico
contar_disponibles_nivel(Nivel, Total) :-
    findall(Id, desarrollador(Id, _, Nivel), Lista),
    length(Lista, Total).

% Cuenta cuántos desarrolladores de ese nivel se requieren para un proyecto
contar_requeridos_nivel(Complejidad, Nivel, Total) :-
    requiere_personal(Complejidad, ListaPerfiles),
    findall(Nivel, member(Nivel, ListaPerfiles), Requeridos),
    length(Requeridos, Total).

% REQUISITO 3: Saber si se tiene el personal suficiente para un proyecto dado
tiene_personal_necesario(ProyectoId) :-
    proyecto(ProyectoId, _, Complejidad),
    contar_disponibles_nivel(junior, DispJun),
    contar_disponibles_nivel(avanzado, DispAva),
    contar_disponibles_nivel(senior, DispSen),
    contar_requeridos_nivel(Complejidad, junior, ReqJun),
    contar_requeridos_nivel(Complejidad, avanzado, ReqAva),
    contar_requeridos_nivel(Complejidad, senior, ReqSen),
    DispJun >= ReqJun,
    DispAva >= ReqAva,
    DispSen >= ReqSen.

% REQUISITO 4: Calcular qué vacantes o personal falta contratar
calcular_faltantes(Complejidad, FaltantesJSON) :-
    % Validación para Junior
    contar_disponibles_nivel(junior, DispJun),
    contar_requeridos_nivel(Complejidad, junior, ReqJun),
    DeficitJun is ReqJun - DispJun,
    (DeficitJun > 0 -> FaltasJun = DeficitJun ; FaltasJun = 0),

    % Validación para Avanzado
    contar_disponibles_nivel(avanzado, DispAva),
    contar_requeridos_nivel(Complejidad, avanzado, ReqAva),
    DeficitAva is ReqAva - DispAva,
    (DeficitAva > 0 -> FaltasAva = DeficitAva ; FaltasAva = 0),

    % Validación para Senior
    contar_disponibles_nivel(senior, DispSen),
    contar_requeridos_nivel(Complejidad, senior, ReqSen),
    DeficitSen is ReqSen - DispSen,
    (DeficitSen > 0 -> FaltasSen = DeficitSen ; FaltasSen = 0),

    FaltantesJSON = json([junior=FaltasJun, avanzado=FaltasAva, senior=FaltasSen]).

% Algoritmo para estructurar el equipo si hay cupo
buscar_equipo([], _, []).
buscar_equipo([Perfil|RestoPerfiles], Disponibles, [DevId|RestoEquipo]) :-
    member(DevId, Disponibles),
    desarrollador(DevId, _, Perfil),
    select(DevId, Disponibles, NuevosDisponibles),
    buscar_equipo(RestoPerfiles, NuevosDisponibles, RestoEquipo).

equipo_para_proyecto(ProyectoId, EquipoNombres) :-
    proyecto(ProyectoId, _, Complejidad),
    requiere_personal(Complejidad, PerfilesRequeridos),
    findall(Id, desarrollador(Id, _, _), TodosLosDevs),
    buscar_equipo(PerfilesRequeridos, TodosLosDevs, EquipoIds),
    findall(Nombre, (member(Id, EquipoIds), desarrollador(Id, Nombre, _)), EquipoNombres).

% ==============================================================================
% 3. ENRUTAMIENTO Y ENDPOINTS HTTP
% ==============================================================================

:- http_handler(root(programadores), handle_programadores, []).
:- http_handler(root(proyectos),     handle_proyectos,     []).
:- http_handler(root(asignar),       handle_asignar,       []).

iniciar_servidor(Puerto) :-
    http_server(http_dispatch, [port(Puerto)]),
    format('~n========================================================~n'),
    format(' Servidor HTTP activo en http://localhost:~w/~n', [Puerto]),
    format('========================================================~n').

% 1. Lista de desarrolladores con sus niveles
handle_programadores(_Request) :-
    findall(json([id=Id, nombre=Nom, nivel=Niv]), desarrollador(Id, Nom, Niv), JSONData),
    reply_json(JSONData).

% 2. Lista de proyectos con sus niveles
handle_proyectos(_Request) :-
    findall(json([id=Id, nombre=Nom, nivel=Niv]), proyecto(Id, Nom, Niv), JSONData),
    reply_json(JSONData).

% 3 y 4. Verificación de personal y reporte de contratación por proyecto
handle_asignar(Request) :-
    catch(
        http_parameters(Request, [id(ProyectoAtom, [atom])]),
        _,
        ProyectoAtom = ninguno
    ),
    (   ProyectoAtom \== ninguno, proyecto(ProyectoAtom, NombreP, NivelP) ->
        calcular_faltantes(NivelP, Faltantes),
        (   tiene_personal_necesario(ProyectoAtom) ->
            PersonalSuficiente = true,
            equipo_para_proyecto(ProyectoAtom, Integrantes)
        ;   PersonalSuficiente = false,
            Integrantes = []
        ),
        reply_json(json([
            proyecto = NombreP,
            nivel_dificultad = NivelP,
            tiene_personal_suficiente = PersonalSuficiente,
            equipo_sugerido = Integrantes,
            necesita_contratar = Faltantes
        ]))
    ;   reply_json(json([status = 'Error', message = 'Proyecto no encontrado']), [status(400)])
    ).