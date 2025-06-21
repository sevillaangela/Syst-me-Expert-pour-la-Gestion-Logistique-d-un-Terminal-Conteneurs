% =====================================================
% SYSTÈME EXPERT POUR LA PLANIFICATION ET ARRIVÉE DU NAVIRE
% Terminal à Conteneurs - Port Autonome de Kribi
% =====================================================

% =====================================================
% MODULE 1. PLANIFICATION ET ARRIVÉE DU NAVIRE
% =====================================================

% Prédictions d'arrivée basées sur les données AIS
% prediction_arrivee(NavireID, DatePrevue, HeurePrevue, Retard, Fiabilite)
prediction_arrivee(nav001, '2025-05-29', '06:00', 0, 95).
prediction_arrivee(nav002, '2025-05-29', '10:30', 30, 88).
prediction_arrivee(nav003, '2025-05-30', '08:15', 15, 92).
prediction_arrivee(nav004, '2025-05-28', '14:00', -60, 98).
prediction_arrivee(nav005, '2025-05-30', '16:00', 0, 90).

% État du trafic maritime en temps réel
% trafic_maritime(Zone, Densite, VitesseMoyenne, Conditions)
trafic_maritime(approche_kribi, faible, 12, normale).
trafic_maritime(golfe_guinee, moyenne, 10, dense).
trafic_maritime(zone_mouillage, forte, 6, congestionne).

% Services de pilotage disponibles
% pilote(ID, Nom, Statut, Specialite, ExperienceAnnees)
pilote(pilot001, 'Capitaine Mbarga', disponible, grands_navires, 15).
pilote(pilot002, 'Capitaine Nkomo', disponible, conteneurs, 12).
pilote(pilot003, 'Capitaine Ekindi', en_service, petroliers, 18).
pilote(pilot004, 'Capitaine Fouda', repos, tous_types, 10).

% Planification des créneaux d'arrivée
% creneau_arrivee(Heure, Duree, Statut, NavireReserve)
creneau_arrivee('06:00', 120, reserve, nav001).
creneau_arrivee('08:00', 90, libre, null).
creneau_arrivee('10:00', 150, reserve, nav002).
creneau_arrivee('12:00', 60, libre, null).
creneau_arrivee('14:00', 180, libre, null).

% Règles de planification d'arrivée
planifier_arrivee(NavireID, DateArrivee, HeureOptimale, PiloteAssigne) :-
    prediction_arrivee(NavireID, DateArrivee, HeurePrevue, Retard, Fiabilite),
    Fiabilite > 85,
    calculer_heure_optimale(HeurePrevue, Retard, HeureOptimale),
    assigner_pilote(NavireID, PiloteAssigne),
    verifier_disponibilite_creneau(HeureOptimale).

% Calcul de l'heure optimale d'arrivée
calculer_heure_optimale(HeurePrevue, Retard, HeureOptimale) :-
    atom_codes(HeurePrevue, CodesHeure),
    % Simulation simple du calcul
    (Retard =< 0 -> HeureOptimale = HeurePrevue
    ; HeureOptimale = HeurePrevue).

% Attribution automatique de pilote
assigner_pilote(NavireID, PiloteID) :-
    navire(NavireID, _, Longueur, _, _, Capacite, _),
    (Longueur > 300 -> 
        pilote(PiloteID, _, disponible, grands_navires, _)
    ; Capacite > 10000 ->
        pilote(PiloteID, _, disponible, conteneurs, _)
    ; pilote(PiloteID, _, disponible, tous_types, _)).

% Vérification de la disponibilité des créneaux
verifier_disponibilite_creneau(Heure) :-
    creneau_arrivee(Heure, _, libre, null).

% Notification automatique aux parties prenantes
generer_notification_arrivee(NavireID, TypeNotification, Destinataires) :-
    navire(NavireID, NomNavire, _, _, _, _, Compagnie),
    prediction_arrivee(NavireID, Date, Heure, Retard, _),
    (Retard > 60 -> TypeNotification = retard_important
    ; Retard > 30 -> TypeNotification = retard_modere
    ; Retard < -30 -> TypeNotification = avance
    ; TypeNotification = normal),
    determiner_destinataires(TypeNotification, Destinataires).

determiner_destinataires(retard_important, [autorite_portuaire, douanes, armateur, terminal]).
determiner_destinataires(retard_modere, [autorite_portuaire, armateur]).
determiner_destinataires(avance, [terminal, pilotage]).
determiner_destinataires(normal, [terminal]).

% =====================================================
% 2. BASE DE CONNAISSANCES - DÉFINITIONS DES STRUCTURES
% =====================================================

% Structure d'un navire
% navire(ID, Nom, Longueur, Largeur, TirantEau, Capacite_EVP, Compagnie)
navire(nav001, 'MSC Gülsün', 400, 61, 16, 23756, 'MSC').
navire(nav002, 'CMA CGM Marco Polo', 396, 54, 16, 16020, 'CMA CGM').
navire(nav003, 'Maersk Madrid', 347, 45, 14, 14000, 'Maersk').
navire(nav004, 'Kribi Express', 180, 28, 8, 1500, 'Local Shipping').
navire(nav005, 'COSCO Shipping', 366, 51, 15, 19000, 'COSCO').

% Structure des quais disponibles
% quai(ID, Nom, Longueur, Largeur, TirantEauMax, NbPortiques, Statut)
quai(q1, 'Quai Principal A', 450, 50, 18, 6, disponible).
quai(q2, 'Quai Principal B', 400, 45, 17, 4, disponible).
quai(q3, 'Quai Secondaire C', 250, 35, 12, 2, disponible).
quai(q4, 'Quai Maintenance', 200, 30, 10, 1, maintenance).

% Structure des conteneurs dans le manifeste
% conteneur(ID, Type, Poids, Destination, Priorite, Statut_Douane)
conteneur(cont001, 'standard_20', 18000, 'douala', normale, 'declare').
conteneur(cont002, 'refrigere_40', 25000, 'ndjamena', haute, 'en_attente').
conteneur(cont003, 'standard_40', 22000, 'yaounde', normale, 'declare').
conteneur(cont004, 'dangereuse_20', 15000, 'bangui', tres_haute, 'inspection_requise').

% Conditions météorologiques
% meteo(Date, Heure, Vent_Vitesse, Visibilite, Etat_Mer)
meteo('2025-05-28', '08:00', 15, bonne, calme).
meteo('2025-05-28', '14:00', 25, moyenne, agitee).
meteo('2025-05-28', '20:00', 35, mauvaise, houleuse).

% =====================================================
% 3. BASE DE FAITS - ÉTAT ACTUEL DU SYSTÈME
% =====================================================

% Arrivées programmées
% arrivee_programmee(NavireID, DateArrivee, HeureArrivee, NbConteneurs)
arrivee_programmee(nav001, '2025-05-29', '06:00', 3000).
arrivee_programmee(nav002, '2025-05-29', '10:00', 2500).
arrivee_programmee(nav003, '2025-05-30', '08:00', 1800).

% Réservations de quais existantes
% reservation_quai(QuaiID, DateDebut, DateFin, NavireID)
reservation_quai(q2, '2025-05-28', '2025-05-29', nav004).

% Capacité de stockage disponible (en EVP)
capacite_stockage_disponible(5000).

% État des équipements
% equipement(Type, ID, Statut, Capacite_Heure)
equipement(portique_sts, sts001, operationnel, 50).
equipement(portique_sts, sts002, operationnel, 45).
equipement(portique_sts, sts003, maintenance, 0).
equipement(portique_rtg, rtg001, operationnel, 25).
equipement(portique_rtg, rtg002, operationnel, 30).

% =====================================================
% 4. RÈGLES D'INFÉRENCE - MOTEUR D'EXPERTISE
% =====================================================

% Règle pour vérifier la compatibilité navire-quai
compatible_navire_quai(NavireID, QuaiID) :-
    navire(NavireID, _, LongueurNav, _, TirantEauNav, _, _),
    quai(QuaiID, _, LongueurQuai, _, TirantEauMaxQuai, _, disponible),
    LongueurNav =< LongueurQuai,
    TirantEauNav =< TirantEauMaxQuai.

% Règle pour vérifier la disponibilité d'un quai à une date
quai_disponible(QuaiID, Date) :-
    quai(QuaiID, _, _, _, _, _, disponible),
    \+ reservation_quai(QuaiID, DateDebut, DateFin, _),
    true.

% Alternative: quai disponible si pas de conflit de dates
quai_disponible(QuaiID, Date) :-
    quai(QuaiID, _, _, _, _, _, disponible),
    reservation_quai(QuaiID, DateDebut, DateFin, _),
    Date \= DateDebut,
    Date \= DateFin.

% Règle pour calculer le temps d'accostage estimé
temps_accostage_estime(NavireID, TempsHeures) :-
    navire(NavireID, _, _, _, _, CapaciteEVP, _),
    arrivee_programmee(NavireID, _, _, NbConteneurs),
    TempsHeures is (NbConteneurs / 50) + 2.

% Règle pour évaluer la priorité d'accostage
priorite_accostage(NavireID, Priorite) :-
    navire(NavireID, _, _, _, _, CapaciteEVP, Compagnie),
    arrivee_programmee(NavireID, _, _, NbConteneurs),
    (   CapaciteEVP > 15000 -> Priorite = haute
    ;   Compagnie = 'Local Shipping' -> Priorite = normale
    ;   NbConteneurs > 2000 -> Priorite = haute
    ;   Priorite = normale
    ).

% Règle pour vérifier les conditions météorologiques
conditions_meteo_favorables(Date, Heure) :-
    meteo(Date, Heure, VitesseVent, Visibilite, EtatMer),
    VitesseVent =< 30,
    Visibilite \= mauvaise,
    EtatMer \= houleuse.

% Règle pour planifier l'attribution d'un quai
planifier_attribution_quai(NavireID, QuaiID, Date, Heure) :-
    arrivee_programmee(NavireID, Date, Heure, _),
    compatible_navire_quai(NavireID, QuaiID),
    quai_disponible(QuaiID, Date),
    conditions_meteo_favorables(Date, Heure),
    priorite_accostage(NavireID, _).

% Règle pour vérifier la capacité de stockage suffisante
capacite_stockage_suffisante(NavireID) :-
    arrivee_programmee(NavireID, _, _, NbConteneurs),
    capacite_stockage_disponible(CapaciteDisponible),
    NbConteneurs =< CapaciteDisponible.

% Règle pour vérifier la disponibilité des équipements
equipements_disponibles(NavireID) :-
    arrivee_programmee(NavireID, _, _, NbConteneurs),
    findall(Capacite, equipement(portique_sts, _, operationnel, Capacite), Capacites),
    sum_list(Capacites, CapaciteTotale),
    TempsNecessaire is NbConteneurs / CapaciteTotale,
    TempsNecessaire =< 24.

% Règle principale pour autoriser l'accostage
autoriser_accostage(NavireID, QuaiID, Date, Heure, Recommandations) :-
    planifier_attribution_quai(NavireID, QuaiID, Date, Heure),
    capacite_stockage_suffisante(NavireID),
    equipements_disponibles(NavireID),
    generer_recommandations(NavireID, QuaiID, Recommandations).

% Règle pour générer des recommandations
generer_recommandations(NavireID, QuaiID, Recommandations) :-
    navire(NavireID, NomNavire, _, _, _, _, _),
    quai(QuaiID, NomQuai, _, _, _, NbPortiques, _),
    temps_accostage_estime(NavireID, Temps),
    priorite_accostage(NavireID, Priorite),
    Recommandations = [
        navire(NomNavire),
        quai_assigne(NomQuai),
        portiques_requis(NbPortiques),
        temps_estime(Temps),
        priorite(Priorite)
    ].

% =====================================================
% 5. REQUÊTES DE CONTRÔLE DOUANIER
% =====================================================

% Vérifier si tous les conteneurs sont déclarés
conteneurs_declares(NavireID) :-
    arrivee_programmee(NavireID, _, _, _),
    \+ (conteneur(ContID, _, _, _, _, StatutDouane),
        StatutDouane \= 'declare').

% Identifier les conteneurs nécessitant une inspection
conteneurs_inspection_requise(NavireID, ListeConteneurs) :-
    arrivee_programmee(NavireID, _, _, _),
    findall(ContID, 
           (conteneur(ContID, Type, _, _, Priorite, _),
            (Type = 'dangereuse_20' ; Type = 'dangereuse_40' ; Priorite = tres_haute)),
           ListeConteneurs).

% =====================================================
% 6. OPTIMISATION DES OPÉRATIONS
% =====================================================

% Optimiser l'ordre de traitement des navires
optimiser_ordre_navires(ListeNavires, ListeOptimisee) :-
    findall(NavireID-Priorite, 
           (arrivee_programmee(NavireID, _, _, _),
            priorite_accostage(NavireID, Priorite)),
           ListeNaviresPriorite),
    trier_par_priorite(ListeNaviresPriorite, ListeOptimisee).

% Règle auxiliaire pour trier par priorité
trier_par_priorite([], []).
trier_par_priorite([NavireID-haute|Reste], [NavireID|ResteOptimise]) :-
    trier_par_priorite(Reste, ResteOptimise).
trier_par_priorite([NavireID-normale|Reste], ListeOptimisee) :-
    trier_par_priorite(Reste, ResteOptimise),
    append(ResteOptimise, [NavireID], ListeOptimisee).

% =====================================================
% 7. RÈGLES DE SÉCURITÉ ET CONTRAINTES
% =====================================================

% Vérifier les contraintes de sécurité pour les matières dangereuses
contraintes_securite_respectees(NavireID) :-
    arrivee_programmee(NavireID, _, _, _),
    \+ (conteneur(ContID, Type, _, _, _, _),
        (Type = 'dangereuse_20' ; Type = 'dangereuse_40'),
        \+ conteneur(ContID, _, _, _, _, 'inspection_requise')).

% Vérifier la capacité maximale du quai
capacite_quai_respectee(QuaiID, NavireID) :-
    quai(QuaiID, _, _, _, _, NbPortiques, _),
    arrivee_programmee(NavireID, _, _, NbConteneurs),
    CapaciteMaxJournaliere is NbPortiques * 50 * 24,
    NbConteneurs =< CapaciteMaxJournaliere.

% =====================================================
% 8. PRÉDICATS UTILITAIRES
% =====================================================

% Afficher les informations d'un navire
afficher_navire(NavireID) :-
    navire(NavireID, Nom, Longueur, Largeur, TirantEau, Capacite, Compagnie),
    format('Navire: ~w~n', [Nom]),
    format('  - ID: ~w~n', [NavireID]),
    format('  - Dimensions: ~wx~w m~n', [Longueur, Largeur]),
    format('  - Tirant d\'eau: ~w m~n', [TirantEau]),
    format('  - Capacité: ~w EVP~n', [Capacite]),
    format('  - Compagnie: ~w~n', [Compagnie]).

% Afficher le planning d'arrivée
afficher_planning :-
    format('=== PLANNING DES ARRIVÉES ===~n'),
    forall(arrivee_programmee(NavireID, Date, Heure, NbCont),
           (navire(NavireID, Nom, _, _, _, _, _),
            format('~w - ~w à ~w (~w conteneurs)~n', [Date, Nom, Heure, NbCont]))).

% Afficher l'état des quais
afficher_etat_quais :-
    format('=== ÉTAT DES QUAIS ===~n'),
    forall(quai(QuaiID, Nom, Longueur, _, TirantEau, Portiques, Statut),
           format('~w: ~w m, ~w portiques, statut: ~w~n', 
                  [Nom, Longueur, Portiques, Statut])).

% =====================================================
% 9. PRÉDICATS DE TEST ET DÉMONSTRATION
% =====================================================

% Test complet du système pour un navire
test_planification(NavireID) :-
    format('=== TEST DE PLANIFICATION POUR ~w ===~n', [NavireID]),
    afficher_navire(NavireID),
    nl,
    (   autoriser_accostage(NavireID, QuaiID, Date, Heure, Recommandations) ->
        format('ACCOSTAGE AUTORISÉ~n'),
        format('Quai assigné: ~w~n', [QuaiID]),
        format('Date/Heure: ~w à ~w~n', [Date, Heure]),
        format('Recommandations: ~w~n', [Recommandations])
    ;   format('ACCOSTAGE REFUSÉ - Vérifier les contraintes~n')
    ),
    nl.

% Test de tous les navires programmés
test_tous_navires :-
    format('=== TEST DE TOUS LES NAVIRES PROGRAMMÉS ===~n'),
    forall(arrivee_programmee(NavireID, _, _, _),
           test_planification(NavireID)).

% Test des équipements disponibles
test_equipements :-
    format('=== ÉTAT DES ÉQUIPEMENTS ===~n'),
    forall(equipement(Type, ID, Statut, Capacite),
           format('~w ~w: ~w (~w/h)~n', [Type, ID, Statut, Capacite])).