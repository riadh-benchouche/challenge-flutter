import { initializeApp } from 'firebase/app';
import {
  experimentalSetDeliveryMetricsExportedToBigQueryEnabled,
  getMessaging,
  isSupported,
  onBackgroundMessage,
} from 'firebase/messaging/sw';

// Déclare le Service Worker global
declare var self: ServiceWorkerGlobalScope;

// Gestion de l'installation du Service Worker
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Install Event', event);
  // Vous pouvez ajouter `self.skipWaiting()` ici si vous voulez activer immédiatement un nouveau Service Worker.
});

// Gestion de l'activation du Service Worker
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activate Event', event);
  // Nettoyez les anciens caches ou données inutiles ici si nécessaire.
});

const app = initializeApp({
  apiKey: 'AIzaSyB7wZb2tO1-Fs6GbDADUSTs2Qs3w08Hovw',
  appId: '1:406099696497:web:87e25e51afe982cd3574d0',
  messagingSenderId: '406099696497',
  projectId: 'flutterfire-e2e-tests',
  authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
  databaseURL:
    'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  storageBucket: 'flutterfire-e2e-tests.appspot.com',
  measurementId: 'G-JN95N1JV2E',
});

// Vérifiez si Firebase Messaging est supporté
isSupported().then((supported) => {
  if (supported) {
    console.log('[Service Worker] Firebase Messaging is supported');
    const messaging = getMessaging(app);

    // Activer l'exportation des métriques de livraison vers BigQuery (facultatif)
    experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true);

    // Gestion des messages reçus en arrière-plan
    onBackgroundMessage(messaging, (payload) => {
      console.log('[Service Worker] Message reçu en arrière-plan', payload);

      // Extraire les données de la notification
      const { title, body, image } = payload.notification ?? {};
      const notificationOptions = {
        body: body || 'Vous avez une nouvelle notification.',
        icon: image || '/assets/icons/icon-72x72.png', // Assurez-vous que ce fichier existe
        data: payload.data, // Attachez des données supplémentaires si nécessaire
        actions: [
          {
            action: 'open_url',
            title: 'Voir plus',
          },
        ],
      };

      if (title) {
        // Afficher la notification
        self.registration.showNotification(title, notificationOptions);
      }
    });
  } else {
    console.warn('[Service Worker] Firebase Messaging is not supported');
  }
});

self.addEventListener('notificationclick', (event) => {
  console.log('[Service Worker] Notification click received.', event);
  event.notification.close(); // Fermez la notification après le clic

  // Ouvrir une URL spécifique si définie dans les actions de la notification
  if (event.action === 'open_url' && event.notification.data?.url) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url) // Ouvre la fenêtre ou l'onglet
    );
  }
});
