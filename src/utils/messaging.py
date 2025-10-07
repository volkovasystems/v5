#!/usr/bin/env python3
"""
V5 RabbitMQ Messaging System
Handles all inter-window communication and external integrations
"""

import json
import logging
import threading
import time
from datetime import datetime
from typing import Dict, Callable, Optional, Any
from pathlib import Path

try:
    import pika
    PIKA_AVAILABLE = True
except ImportError:
    PIKA_AVAILABLE = False
    print("Warning: pika not available. Install with: pip install pika")

class V5MessageBus:
    """Central message bus for V5 tool communication"""
    
    def __init__(self, config_path: Path):
        self.config_path = config_path
        self.config = self.load_config()
        self.connection = None
        self.channel = None
        self.logger = logging.getLogger(f'V5MessageBus')
        self.consumers = {}
        self.is_connected = False
        
        if PIKA_AVAILABLE:
            self.connect()
        else:
            self.logger.warning(
                "RabbitMQ messaging disabled - pika not available"
            )
    
    def load_config(self) -> Dict:
        """Load messaging configuration"""
        try:
            with open(self.config_path) as f:
                config = json.load(f)
            return config.get('rabbitmq', {})
        except (FileNotFoundError, json.JSONDecodeError) as e:
            self.logger.error(f"Failed to load config: {e}")
            return self.get_default_config()
    
    def get_default_config(self) -> Dict:
        """Get default RabbitMQ configuration"""
        return {
            "host": "localhost",
            "port": 5672,
            "virtual_host": "/",
            "username": "guest",
            "password": "guest",
            "exchanges": {
                "window.activities": "topic",
                "code.changes": "topic", 
                "protocol.updates": "topic",
                "governance.reviews": "topic",
                "feature.insights": "topic"
            }
        }
    
    def connect(self) -> bool:
        """Connect to RabbitMQ server"""
        if not PIKA_AVAILABLE:
            return False
        
        try:
            credentials = pika.PlainCredentials(
                self.config['username'], 
                self.config['password']
            )
            
            parameters = pika.ConnectionParameters(
                host=self.config['host'],
                port=self.config['port'],
                virtual_host=self.config['virtual_host'],
                credentials=credentials,
                heartbeat=600,
                blocked_connection_timeout=300
            )
            
            self.connection = pika.BlockingConnection(parameters)
            self.channel = self.connection.channel()
            
            # Setup exchanges
            self.setup_exchanges()
            
            self.is_connected = True
            self.logger.info("Connected to RabbitMQ")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to connect to RabbitMQ: {e}")
            self.is_connected = False
            return False
    
    def setup_exchanges(self):
        """Setup RabbitMQ exchanges and queues"""
        if not self.is_connected or not self.channel:
            return
        
        try:
            # Declare exchanges
            for exchange, exchange_type in self.config['exchanges'].items():
                self.channel.exchange_declare(
                    exchange=exchange,
                    exchange_type=exchange_type,
                    durable=True
                )
                self.logger.info(f"Declared exchange: {exchange}")
            
            # Declare common queues
            queues = [
                'window_a_activities',
                'window_b_fixes', 
                'window_c_governance',
                'window_d_audits',
                'window_e_features',
                'external_integrations'
            ]
            
            for queue in queues:
                self.channel.queue_declare(queue=queue, durable=True)
                self.logger.info(f"Declared queue: {queue}")
                
        except Exception as e:
            self.logger.error(f"Failed to setup exchanges: {e}")
    
    def publish_message(
        self, exchange: str, routing_key: str, 
        message: Dict[str, Any], window_id: str = None
    ):
        """Publish a message to the message bus"""
        if not self.is_connected or not self.channel:
            self.logger.warning(
                f"Not connected - message dropped: {routing_key}"
            )
            return False
        
        try:
            # Enrich message with metadata
            enriched_message = {
                'timestamp': datetime.now().isoformat(),
                'source_window': window_id,
                'routing_key': routing_key,
                'data': message
            }
            
            self.channel.basic_publish(
                exchange=exchange,
                routing_key=routing_key,
                body=json.dumps(enriched_message, indent=2),
                properties=pika.BasicProperties(
                    delivery_mode=2,  # Make message persistent
                    timestamp=int(time.time())
                )
            )
            
            self.logger.debug(f"Published message: {routing_key}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to publish message: {e}")
            return False
    
    def subscribe_to_queue(
        self, queue: str, callback: Callable, window_id: str = None
    ):
        """Subscribe to a queue for message consumption"""
        if not self.is_connected or not self.channel:
            self.logger.warning(
                f"Not connected - cannot subscribe to: {queue}"
            )
            return False
        
        def message_handler(ch, method, properties, body):
            try:
                message = json.loads(body)
                callback(message, window_id)
                ch.basic_ack(delivery_tag=method.delivery_tag)
            except Exception as e:
                self.logger.error(f"Error processing message: {e}")
                ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
        
        try:
            self.channel.basic_consume(
                queue=queue,
                on_message_callback=message_handler
            )
            
            self.consumers[queue] = True
            self.logger.info(f"Subscribed to queue: {queue}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to subscribe to queue {queue}: {e}")
            return False
    
    def start_consuming(self, blocking=True):
        """Start consuming messages"""
        if not self.is_connected or not self.channel:
            return
        
        if blocking:
            try:
                self.logger.info("Starting message consumption (blocking)")
                self.channel.start_consuming()
            except KeyboardInterrupt:
                self.logger.info("Stopping message consumption")
                self.channel.stop_consuming()
        else:
            # Start consuming in a separate thread
            def consume():
                try:
                    self.channel.start_consuming()
                except Exception as e:
                    self.logger.error(f"Error in message consumption: {e}")
            
            consumer_thread = threading.Thread(target=consume, daemon=True)
            consumer_thread.start()
            self.logger.info("Started message consumption (non-blocking)")
    
    def close(self):
        """Close connection to RabbitMQ"""
        if self.connection and not self.connection.is_closed:
            try:
                if self.channel:
                    self.channel.stop_consuming()
                self.connection.close()
                self.is_connected = False
                self.logger.info("Disconnected from RabbitMQ")
            except Exception as e:
                self.logger.error(f"Error closing connection: {e}")

class WindowMessenger:
    """Simplified messaging interface for individual windows"""
    
    def __init__(self, window_id: str, message_bus: V5MessageBus):
        self.window_id = window_id
        self.message_bus = message_bus
        self.logger = logging.getLogger(f'WindowMessenger-{window_id}')
    
    def send_activity(self, activity_type: str, data: Dict):
        """Send window activity message"""
        return self.message_bus.publish_message(
            exchange='window.activities',
            routing_key=f'{self.window_id}.activity.{activity_type}',
            message=data,
            window_id=self.window_id
        )
    
    def send_code_change(self, change_type: str, data: Dict):
        """Send code change notification"""
        return self.message_bus.publish_message(
            exchange='code.changes',
            routing_key=f'{self.window_id}.code.{change_type}',
            message=data,
            window_id=self.window_id
        )
    
    def send_protocol_update(self, update_type: str, data: Dict):
        """Send protocol update (Window C only)"""
        if self.window_id != 'window_c':
            self.logger.warning("Only Window C can send protocol updates")
            return False
        
        return self.message_bus.publish_message(
            exchange='protocol.updates',
            routing_key=f'protocol.{update_type}',
            message=data,
            window_id=self.window_id
        )
    
    def send_governance_review(self, review_type: str, data: Dict):
        """Send governance review (Window D only)"""
        if self.window_id != 'window_d':
            self.logger.warning("Only Window D can send governance reviews")
            return False
        
        return self.message_bus.publish_message(
            exchange='governance.reviews',
            routing_key=f'governance.{review_type}',
            message=data,
            window_id=self.window_id
        )
    
    def send_feature_insight(self, insight_type: str, data: Dict):
        """Send feature insight (Window E only)"""
        if self.window_id != 'window_e':
            self.logger.warning("Only Window E can send feature insights")
            return False
        
        return self.message_bus.publish_message(
            exchange='feature.insights',
            routing_key=f'feature.{insight_type}',
            message=data,
            window_id=self.window_id
        )
    
    def listen_for_protocol_updates(self, callback: Callable):
        """Listen for protocol updates (Windows A & B)"""
        if self.window_id not in ['window_a', 'window_b']:
            self.logger.warning("Only Windows A & B should listen for protocol updates")
            return False
        
        queue = f'{self.window_id}_protocol_updates'
        
        # Bind queue to protocol updates exchange
        if self.message_bus.is_connected:
            self.message_bus.channel.queue_declare(queue=queue, durable=True)
            self.message_bus.channel.queue_bind(
                exchange='protocol.updates',
                queue=queue,
                routing_key='protocol.*'
            )
        
        return self.message_bus.subscribe_to_queue(queue, callback, self.window_id)
    
    def listen_for_governance_feedback(self, callback: Callable):
        """Listen for governance feedback (Window C only)"""
        if self.window_id != 'window_c':
            self.logger.warning("Only Window C should listen for governance feedback")
            return False
        
        queue = f'{self.window_id}_governance_feedback'
        
        if self.message_bus.is_connected:
            self.message_bus.channel.queue_declare(queue=queue, durable=True)
            self.message_bus.channel.queue_bind(
                exchange='governance.reviews',
                queue=queue,
                routing_key='governance.*'
            )
        
        return self.message_bus.subscribe_to_queue(queue, callback, self.window_id)

# Convenience functions for offline mode
class OfflineMessenger:
    """Fallback messenger when RabbitMQ is not available"""
    
    def __init__(self, window_id: str):
        self.window_id = window_id
        self.logger = logging.getLogger(f'OfflineMessenger-{window_id}')
    
    def send_activity(self, activity_type: str, data: Dict):
        self.logger.info(f"[OFFLINE] Activity: {activity_type} - {data}")
        return True
    
    def send_code_change(self, change_type: str, data: Dict):
        self.logger.info(f"[OFFLINE] Code Change: {change_type} - {data}")
        return True
    
    def send_protocol_update(self, update_type: str, data: Dict):
        self.logger.info(f"[OFFLINE] Protocol Update: {update_type} - {data}")
        return True
    
    def send_governance_review(self, review_type: str, data: Dict):
        self.logger.info(f"[OFFLINE] Governance Review: {review_type} - {data}")
        return True
    
    def send_feature_insight(self, insight_type: str, data: Dict):
        self.logger.info(f"[OFFLINE] Feature Insight: {insight_type} - {data}")
        return True
    
    def listen_for_protocol_updates(self, callback: Callable):
        self.logger.info("[OFFLINE] Protocol update listening disabled")
        return True
    
    def listen_for_governance_feedback(self, callback: Callable):
        self.logger.info("[OFFLINE] Governance feedback listening disabled")
        return True

def create_messenger(window_id: str, config_path: Path) -> WindowMessenger:
    """Factory function to create appropriate messenger"""
    try:
        message_bus = V5MessageBus(config_path)
        if message_bus.is_connected:
            return WindowMessenger(window_id, message_bus)
        else:
            return OfflineMessenger(window_id)
    except Exception:
        return OfflineMessenger(window_id)