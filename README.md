# Système Expert pour la Gestion Logistique d'un Terminal à Conteneurs

## 🚢 Aperçu du Projet

Ce projet présente un système expert développé en Prolog avec interface web Node.js pour automatiser et optimiser les opérations logistiques du terminal à conteneurs du Port Autonome de Kribi. Le système intègre intelligence artificielle et programmation logique pour gérer six modules opérationnels essentiels.

## 🎯 Objectifs

- **Automatisation** des processus de décision complexes
- **Optimisation** des ressources portuaires (quais, grues, zones de stockage)
- **Intégration** des contraintes de sécurité et réglementaires
- **Amélioration** de l'efficacité opérationnelle du terminal

## 🏗️ Architecture du Système

### Base de Connaissances
- **Navires** : caractéristiques techniques (longueur, capacité EVP, tirant d'eau)
- **Quais** : dimensions, capacités, équipements disponibles
- **Conteneurs** : types, poids, destinations, statuts douaniers
- **Équipements** : portiques STS/RTG, capacités opérationnelles

### Base de Faits
- Arrivées programmées avec prédictions AIS (fiabilité > 85%)
- Réservations de quais en temps réel
- Conditions météorologiques et trafic maritime
- Capacités de stockage disponibles (5000 EVP)

### Moteur d'Inférences
- Vérification de compatibilité navire-quai
- Optimisation de l'attribution des ressources
- Gestion des contraintes de sécurité et douanières
- Génération de recommandations automatiques

## 📋 Modules Opérationnels

### Module 1 : Planification et Arrivée du Navire
- **Prédictions AIS** avec fiabilité > 85%
- **Attribution automatique** de pilotes selon spécialisation
- **Gestion des créneaux** d'arrivée optimisés
- **Notifications automatiques** aux parties prenantes

### Module 2 : Déchargement des Conteneurs (Ship-to-Shore)
- **Optimisation** des portiques STS
- **Vérification** de compatibilité navire-quai
- **Capacité** de 50 conteneurs/heure par portique
- **Contraintes physiques** automatiquement vérifiées

### Module 3 : Transfert et Empilage dans la Cour
- **Algorithmes d'optimisation** d'empilage
- **Zones spécialisées** (standard, réfrigéré, dangereux)
- **Minimisation** des mouvements futurs
- **Gestion** des conteneurs réfrigérés avec connexions électriques

### Module 4 : Traitement Administratif et Douanier
- **Contrôle douanier automatisé**
- **Sélection intelligente** pour inspections
- **Interface CAMCIS**
- **Vérification** des déclarations automatique

### Module 5 : Chargement pour l'Exportation
- **Optimisation** de l'ordre de traitement
- **Priorités** basées sur capacité navire (> 15000 EVP)
- **Plan de chargement** optimal
- **Critères de stabilité** intégrés

### Module 6 : Transport Terrestre et Sortie du Port
- **Coordination** avec transporteurs
- **Temps de sortie** optimisé (30 min/conteneur)
- **Contraintes de sécurité** obligatoires
- **Gestion des flux** automatisée

## 🔧 Technologies Utilisées

### Backend
- **Prolog** : Moteur d'inférences et règles logiques
- **Node.js/Express** : API RESTful et serveur web
- **JavaScript** : Logique métier et intégration

### Frontend
- **HTML5/CSS3** : Interface utilisateur moderne
- **JavaScript** : Interactions dynamiques
- **API REST** : Communication client-serveur

## 📊 Performances

- **Capacité de traitement** : 50 conteneurs/heure par portique STS
- **Fiabilité des prédictions AIS** : > 85%
- **Temps de sortie moyen** : 30 minutes par conteneur
- **Taux d'inspection douanière** : 10% + matières dangereuses

## 🚀 Installation et Démarrage

### Prérequis
```bash
- Node.js (v14 ou supérieur)
- SWI-Prolog (pour les règles d'inférence)
- npm ou yarn
```

### Installation
```bash
# Cloner le projet
git clone [repository-url]
cd terminal-containers-expert-system

# Installer les dépendances
npm install

# Démarrer le serveur
npm start
```

### Accès
- **Interface web** : http://localhost:3000
- **API REST** : http://localhost:3000/api
- **Dashboard** : http://localhost:3000/api/dashboard

## 📡 API Endpoints

### Module 1 - Planification
```http
POST /api/ship/plan-arrival
Content-Type: application/json

{
  "name": "MSC Gülsün",
  "capacity": 23756,
  "length": 400,
  "operationType": "import"
}
```

### Module 2 - Déchargement
```http
POST /api/ship/unload
Content-Type: application/json

{
  "shipId": "12345",
  "containerCount": 3000
}
```

### Module 3 - Stockage
```http
POST /api/container/assign-storage
Content-Type: application/json

{
  "containerNumber": "CONT001",
  "type": "standard",
  "status": "unloaded",
  "destination": "yaounde"
}
```

### Module 4 - Contrôle Douanier
```http
POST /api/customs/process
Content-Type: application/json

{
  "containers": [
    {
      "number": "CONT001",
      "type": "standard",
      "value": 25000
    }
  ]
}
```

### Module 5 - Chargement
```http
POST /api/ship/load
Content-Type: application/json

{
  "shipId": "12345",
  "containerIds": ["CONT001", "CONT002"]
}
```

### Module 6 - Transport
```http
POST /api/transport/schedule
Content-Type: application/json

{
  "containerIds": ["CONT001"],
  "destination": "douala",
  "transportMode": "truck"
}
```

## 🧪 Tests et Validation

### Tests Prolog
```prolog
% Test complet du système
?- test_tous_navires.

% Test pour un navire spécifique
?- test_planification(nav001).

% Affichage du planning
?- afficher_planning.

% État des équipements
?- test_equipements.
```

### Tests API
```bash
# Test de santé du système
curl http://localhost:3000/api/status

# Test du tableau de bord
curl http://localhost:3000/api/dashboard
```

## 📈 Métriques de Performance

### Règles d'Inférence
- **40+ règles logiques** pour l'optimisation
- **Moteur d'inférences** avec chaînage avant/arrière
- **Base de connaissances** extensible et modulaire

### Optimisations
- **Attribution automatique** de ressources
- **Calcul de temps d'accostage** en temps réel
- **Gestion des priorités** intelligente
- **Recommandations contextuelles**

## 🛡️ Sécurité et Contraintes

### Contraintes de Sécurité
- Vérification automatique des matières dangereuses
- Respect des capacités maximales des quais
- Gestion des conditions météorologiques
- Protocoles d'urgence intégrés

### Contrôles Douaniers
- Sélection basée sur l'analyse de risque
- Interface avec systèmes douaniers
- Traçabilité complète des opérations
- Respect des réglementations CEMAC

## 🔮 Perspectives d'Amélioration

- **Machine Learning** pour optimisation prédictive
- **Extension** aux opérations de transbordement
- **Interface** avec systèmes douaniers régionaux
- **Intégration IoT** pour capteurs temps réel
- **Tableau de bord** avancé avec visualisations

## 👥 Équipe de Développement

**Groupe 4 - ENSP Yaoundé**
- NJIKI TCHOUBIA MIGUEL 22p533 (Chef de groupe)
- MAGNE Isabelle Christ 22p380
- MVOGO MVOGO David Roland 22p226
- NGUEPI NGUEDIA ILAN TORRES 22P327
- NGOUPEYOU Bryan Jean-Roland 22P248
- NZIÉLEU NGNOULAYE Magdiel Nathan 22P587
- NZIKO TALLA NZIKO Félix André 22P325
- PAFE MEKONTSO DILANE 22P486
- SAKAM FOTSING Emmanuel 22P256
- TAGNE TEGUEO KUATE FREEDY-JULIO 22P245
- TOMO MBIANDA Angela Katia 22P563

**Responsable** : Dr. Louis Fippo Fitime
**Année académique** : 2024-2025

## 📄 Licence

Ce projet est développé dans le cadre académique à l'École Nationale Supérieure Polytechnique de Yaoundé, Département de Génie Informatique.

---

**🚢 Système Expert Terminal à Conteneurs - Port Autonome de Kribi**
*Intelligence Artificielle appliquée à la logistique portuaire*