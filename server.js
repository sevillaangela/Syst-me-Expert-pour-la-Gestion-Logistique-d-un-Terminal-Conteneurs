const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Base de connaissances du système expert
const knowledgeBase = {
    quays: [
        { id: 'Q1', name: 'Quai 1 - Zone A', maxLength: 300, maxCapacity: 3000, status: 'available' },
        { id: 'Q2', name: 'Quai 2 - Zone B', maxLength: 400, maxCapacity: 5000, status: 'occupied' },
        { id: 'Q3', name: 'Quai 3 - Zone C', maxLength: 250, maxCapacity: 2000, status: 'maintenance' }
    ],
    cranes: [
        { id: 'STS01', type: 'Ship-to-Shore', capacity: 50, status: 'active' },
        { id: 'STS02', type: 'Ship-to-Shore', capacity: 45, status: 'active' },
        { id: 'RTG01', type: 'Rubber-Tyred Gantry', capacity: 30, status: 'active' },
        { id: 'RTG02', type: 'Rubber-Tyred Gantry', capacity: 30, status: 'maintenance' }
    ],
    storageZones: [
        { id: 'A1', type: 'standard', capacity: 1200, occupied: 850 },
        { id: 'R1', type: 'refrigerated', capacity: 200, occupied: 120 },
        { id: 'D1', type: 'dangerous', capacity: 100, occupied: 30 },
        { id: 'E1', type: 'export', capacity: 800, occupied: 600 }
    ]
};

// Base de faits (état actuel du terminal)
let factBase = {
    ships: [],
    containers: [],
    operations: [],
    stats: {
        totalContainers: 1600,
        availableQuays: 1,
        activeCranes: 3,
        operationsToday: 42
    }
};

// Moteur d'inférences - Règles du système expert
class InferenceEngine {
    // Règle d'assignation de quai
    static assignQuay(ship) {
        const availableQuays = knowledgeBase.quays.filter(q => q.status === 'available');
        
        for (let quay of availableQuays) {
            if (ship.length <= quay.maxLength && ship.capacity <= quay.maxCapacity) {
                return {
                    success: true,
                    quay: quay,
                    estimatedTime: Math.ceil(ship.capacity / 50), // 50 conteneurs/heure
                    recommendation: `Navire ${ship.name} assigné au ${quay.name}`
                };
            }
        }
        
        return {
            success: false,
            reason: 'Aucun quai disponible pour ce navire',
            recommendation: 'Attendre la libération d\'un quai approprié'
        };
    }

    // Règle d'assignation de zone de stockage
    static assignStorageZone(container) {
        let targetZone;
        
        // Règles basées sur le type de conteneur
        switch (container.type) {
            case 'refrigere':
                targetZone = knowledgeBase.storageZones.find(z => z.id === 'R1');
                break;
            case 'dangereux':
                targetZone = knowledgeBase.storageZones.find(z => z.id === 'D1');
                break;
            case 'export':
                targetZone = knowledgeBase.storageZones.find(z => z.id === 'E1');
                break;
            default:
                targetZone = knowledgeBase.storageZones.find(z => z.id === 'A1');
        }

        // Vérifier la capacité
        if (targetZone && targetZone.occupied < targetZone.capacity) {
            const position = this.calculateOptimalPosition(targetZone);
            return {
                success: true,
                zone: targetZone,
                position: position,
                recommendation: `Conteneur ${container.number} assigné à la zone ${targetZone.id}`
            };
        }

        return {
            success: false,
            reason: 'Zone de stockage saturée',
            recommendation: 'Optimiser l\'empilage ou utiliser une zone alternative'
        };
    }

    // Calcul de position optimale
    static calculateOptimalPosition(zone) {
        const row = Math.floor(zone.occupied / 50) + 1;
        const stack = (zone.occupied % 50) + 1;
        const level = Math.floor(stack / 10) + 1;
        
        return {
            bloc: zone.id,
            rangee: row,
            pile: stack,
            niveau: level
        };
    }

    // Règle d'optimisation d'empilage
    static optimizeStacking(zone) {
        const currentEfficiency = (zone.occupied / zone.capacity) * 100;
        const recommendations = [];
        
        if (currentEfficiency > 85) {
            recommendations.push('Zone saturée - Redistribution recommandée');
        } else if (currentEfficiency > 70) {
            recommendations.push('Optimisation de l\'empilage recommandée');
        }
        
        return {
            efficiency: currentEfficiency,
            recommendations: recommendations,
            optimalLayout: this.calculateOptimalLayout(zone)
        };
    }

    static calculateOptimalLayout(zone) {
        return {
            maxHeight: zone.type === 'refrigerated' ? 3 : 5,
            preferredArrangement: 'LIFO', // Last In, First Out
            accessPriority: zone.type === 'export' ? 'high' : 'normal'
        };
    }

    // Règle de maintenance préventive
    static scheduleMaintenancePrevention(equipment) {
        const maintenanceRules = {
            'Ship-to-Shore': { interval: 200, priority: 'high' },
            'Rubber-Tyred Gantry': { interval: 150, priority: 'medium' },
            'Reach Stacker': { interval: 100, priority: 'medium' }
        };
        
        const rule = maintenanceRules[equipment.type];
        if (rule) {
            return {
                nextMaintenance: `Dans ${rule.interval} heures d'opération`,
                priority: rule.priority,
                estimatedDuration: '4-6 heures',
                recommendation: `Planifier maintenance ${equipment.id} - ${rule.priority} priorité`
            };
        }
        
        return { recommendation: 'Equipement non reconnu' };
    }

    // Règle de gestion d'urgence
    static handleEmergency(type, description) {
        const emergencyProtocols = {
            'incendie': {
                priority: 'critique',
                actions: ['Évacuation immédiate', 'Alerte pompiers', 'Arrêt des opérations'],
                estimatedTime: '30-60 minutes'
            },
            'accident': {
                priority: 'haute',
                actions: ['Sécurisation de la zone', 'Alerte médicale', 'Investigation'],
                estimatedTime: '45-90 minutes'
            },
            'panne_equipement': {
                priority: 'moyenne',
                actions: ['Isolation équipement', 'Équipe technique', 'Réallocation ressources'],
                estimatedTime: '60-120 minutes'
            },
            'mauvais_temps': {
                priority: 'moyenne',
                actions: ['Sécurisation conteneurs', 'Arrêt grues', 'Surveillance météo'],
                estimatedTime: '120-240 minutes'
            }
        };
        
        const protocol = emergencyProtocols[type] || emergencyProtocols['accident'];
        
        return {
            protocol: protocol,
            recommendation: `Urgence ${type}: ${protocol.actions.join(', ')}`,
            mobilizedTeams: this.getMobilizedTeams(protocol.priority)
        };
    }

    static getMobilizedTeams(priority) {
        const teams = {
            'critique': ['Sécurité', 'Pompiers', 'Médical', 'Direction'],
            'haute': ['Sécurité', 'Technique', 'Médical'],
            'moyenne': ['Sécurité', 'Technique']
        };
        
        return teams[priority] || teams['moyenne'];
    }

    // Règle de contrôle douanier
    static processCustomsControl(containers) {
        const riskFactors = {
            'origine_sensible': 2,
            'destination_sensible': 1.5,
            'type_dangereux': 3,
            'declarant_nouveau': 1.2,
            'valeur_elevee': 1.8
        };
        
        const results = containers.map(container => {
            let riskScore = 1;
            
            // Calcul du score de risque (simulation)
            if (container.type === 'dangereux') riskScore *= riskFactors.type_dangereux;
            if (container.value > 50000) riskScore *= riskFactors.valeur_elevee;
            
            const needsInspection = riskScore > 2 || Math.random() < 0.1; // 10% inspection aléatoire
            
            return {
                containerNumber: container.number,
                riskScore: riskScore,
                needsInspection: needsInspection,
                inspectionType: needsInspection ? (riskScore > 3 ? 'physique' : 'scanner') : 'aucune',
                estimatedTime: needsInspection ? (riskScore > 3 ? '45 min' : '15 min') : '5 min'
            };
        });
        
        return {
            totalContainers: containers.length,
            toInspect: results.filter(r => r.needsInspection).length,
            results: results,
            recommendation: `${results.filter(r => r.needsInspection).length} conteneurs sélectionnés pour inspection`
        };
    }
}

// Routes API

// Module 1: Planification et arrivée du navire
app.post('/api/ship/plan-arrival', (req, res) => {
    const { name, capacity, length, operationType } = req.body;
    
    const ship = { name, capacity: parseInt(capacity), length: parseInt(length), operationType };
    const result = InferenceEngine.assignQuay(ship);
    
    if (result.success) {
        factBase.ships.push({
            ...ship,
            id: Date.now(),
            assignedQuay: result.quay.id,
            status: 'planned',
            estimatedTime: result.estimatedTime
        });
        
        // Mettre à jour le statut du quai
        const quay = knowledgeBase.quays.find(q => q.id === result.quay.id);
        if (quay) quay.status = 'reserved';
        
        factBase.stats.operationsToday++;
    }
    
    res.json({
        success: result.success,
        message: result.recommendation,
        data: result,
        stats: factBase.stats
    });
});

// Module 2: Déchargement des conteneurs
app.post('/api/ship/unload', (req, res) => {
    const { shipId, containerCount } = req.body;
    
    const ship = factBase.ships.find(s => s.id == shipId);
    if (!ship) {
        return res.json({ success: false, message: 'Navire non trouvé' });
    }
    
    // Simulation du déchargement
    const unloadedContainers = [];
    for (let i = 0; i < containerCount; i++) {
        const container = {
            number: `CONT${Date.now()}-${i}`,
            type: 'standard',
            status: 'unloaded',
            shipId: shipId,
            unloadTime: new Date()
        };
        unloadedContainers.push(container);
        factBase.containers.push(container);
    }
    
    factBase.stats.totalContainers += containerCount;
    
    res.json({
        success: true,
        message: `${containerCount} conteneurs déchargés avec succès`,
        containers: unloadedContainers,
        stats: factBase.stats
    });
});

// Module 3: Transfert et empilage dans la cour
app.post('/api/container/assign-storage', (req, res) => {
    const { containerNumber, type, status, destination } = req.body;
    
    const container = { number: containerNumber, type, status, destination };
    const result = InferenceEngine.assignStorageZone(container);
    
    if (result.success) {
        factBase.containers.push({
            ...container,
            id: Date.now(),
            assignedZone: result.zone.id,
            position: result.position,
            storageTime: new Date()
        });
        
        // Mettre à jour l'occupation de la zone
        result.zone.occupied++;
        factBase.stats.totalContainers++;
    }
    
    res.json({
        success: result.success,
        message: result.recommendation,
        data: result,
        stats: factBase.stats
    });
});

// Module 4: Traitement administratif et douanier
app.post('/api/customs/process', (req, res) => {
    const { containers } = req.body;
    
    const result = InferenceEngine.processCustomsControl(containers);
    
    // Enregistrer les résultats
    factBase.operations.push({
        type: 'customs_control',
        timestamp: new Date(),
        containers: result.results,
        summary: result.recommendation
    });
    
    res.json({
        success: true,
        message: 'Contrôle douanier traité',
        data: result,
        stats: factBase.stats
    });
});

// Module 5: Chargement pour l'exportation
app.post('/api/ship/load', (req, res) => {
    const { shipId, containerIds } = req.body;
    
    const ship = factBase.ships.find(s => s.id == shipId);
    if (!ship) {
        return res.json({ success: false, message: 'Navire non trouvé' });
    }
    
    // Optimisation du plan de chargement
    const loadingPlan = {
        sequence: containerIds.map((id, index) => ({
            containerId: id,
            loadOrder: index + 1,
            estimatedTime: 2 // minutes par conteneur
        })),
        totalTime: containerIds.length * 2,
        stability: 'optimal'
    };
    
    factBase.operations.push({
        type: 'loading',
        shipId: shipId,
        plan: loadingPlan,
        timestamp: new Date()
    });
    
    res.json({
        success: true,
        message: `Plan de chargement généré pour ${containerIds.length} conteneurs`,
        data: loadingPlan,
        stats: factBase.stats
    });
});

// Module 6: Transport terrestre et sortie du port
app.post('/api/transport/schedule', (req, res) => {
    const { containerIds, destination, transportMode } = req.body;
    
    // Calcul du temps de sortie estimé
    const baseTime = 30; // minutes
    const congestionFactor = Math.random() * 0.5 + 0.8; // 0.8 à 1.3
    const estimatedExitTime = Math.ceil(baseTime * congestionFactor);
    
    const transportSchedule = {
        containers: containerIds,
        destination: destination,
        mode: transportMode,
        estimatedExitTime: estimatedExitTime + ' minutes',
        gateAssignment: 'Porte ' + (Math.floor(Math.random() * 3) + 1),
        documentation: 'Complète',
        status: 'approved'
    };
    
    factBase.operations.push({
        type: 'transport_exit',
        schedule: transportSchedule,
        timestamp: new Date()
    });
    
    res.json({
        success: true,
        message: `Transport programmé - Sortie estimée: ${estimatedExitTime} minutes`,
        data: transportSchedule,
        stats: factBase.stats
    });
});

// Routes pour opérations spécialisées
app.post('/api/operations/optimize-stacking', (req, res) => {
    const { zoneId } = req.body;
    
    const zone = knowledgeBase.storageZones.find(z => z.id === zoneId);
    if (!zone) {
        return res.json({ success: false, message: 'Zone non trouvée' });
    }
    
    const result = InferenceEngine.optimizeStacking(zone);
    
    res.json({
        success: true,
        message: `Optimisation zone ${zoneId} - Efficacité: ${result.efficiency.toFixed(1)}%`,
        data: result,
        stats: factBase.stats
    });
});

app.post('/api/operations/maintenance', (req, res) => {
    const { equipmentId } = req.body;
    
    const equipment = knowledgeBase.cranes.find(c => c.id === equipmentId);
    if (!equipment) {
        return res.json({ success: false, message: 'Équipement non trouvé' });
    }
    
    const result = InferenceEngine.scheduleMaintenancePrevention(equipment);
    
    res.json({
        success: true,
        message: result.recommendation,
        data: result,
        stats: factBase.stats
    });
});

app.post('/api/operations/emergency', (req, res) => {
    const { type, description, priority } = req.body;
    
    const result = InferenceEngine.handleEmergency(type, description);
    
    factBase.operations.push({
        type: 'emergency',
        emergencyType: type,
        description: description,
        protocol: result.protocol,
        timestamp: new Date()
    });
    
    res.json({
        success: true,
        message: result.recommendation,
        data: result,
        stats: factBase.stats
    });
});

// Routes d'information
app.get('/api/status', (req, res) => {
    res.json({
        knowledgeBase: knowledgeBase,
        factBase: factBase,
        timestamp: new Date()
    });
});

app.get('/api/dashboard', (req, res) => {
    res.json({
        stats: factBase.stats,
        quays: knowledgeBase.quays,
        cranes: knowledgeBase.cranes,
        storageZones: knowledgeBase.storageZones,
        recentOperations: factBase.operations.slice(-10)
    });
});

// Servir l'interface utilisateur
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Démarrage du serveur
app.listen(PORT, () => {
    console.log(`🚢 Système Expert Terminal à Conteneurs démarré sur le port ${PORT}`);
    console.log(`📊 Interface disponible sur: http://localhost:${PORT}`);
    console.log(`🔧 API disponible sur: http://localhost:${PORT}/api`);
    
    // Initialisation des données de démonstration
    console.log('📋 Initialisation de la base de connaissances...');
    console.log(`✅ ${knowledgeBase.quays.length} quais configurés`);
    console.log(`✅ ${knowledgeBase.cranes.length} grues disponibles`);
    console.log(`✅ ${knowledgeBase.storageZones.length} zones de stockage`);
    console.log('🚀 Système expert opérationnel!');
});