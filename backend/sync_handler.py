import json
import boto3
import os
from datetime import datetime
from typing import Dict, List, Any

dynamodb = boto3.resource('dynamodb', region_name=os.environ.get('AWS_REGION', 'us-east-1'))
EVENTS_TABLE = os.environ.get('DYNAMODB_EVENTS_TABLE', 'shikshasync-events')
STUDENTS_TABLE = os.environ.get('DYNAMODB_STUDENTS_TABLE', 'shikshasync-students')

events_table = dynamodb.Table(EVENTS_TABLE)
students_table = dynamodb.Table(STUDENTS_TABLE)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    POST /sync - Receive mastery events from student app
    Expects: { "events": [ {eventId, studentId, skillId, questionId, isCorrect, masteryBefore, masteryAfter, timestamp} ] }
    """
    try:
        # Parse request body
        if 'body' not in event:
            return _response(400, {'error': 'Missing request body'})

        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        events = body.get('events', [])

        if not events:
            return _response(400, {'error': 'No events provided'})

        # Process each event (idempotent via eventId)
        processed = 0
        duplicates = 0

        with events_table.batch_writer() as batch:
            for evt in events:
                event_id = evt.get('eventId')
                if not event_id:
                    continue

                # Check if event already exists (idempotency)
                existing = events_table.get_item(Key={'event_id': event_id})
                if 'Item' in existing:
                    duplicates += 1
                    continue

                # Store event
                item = {
                    'event_id': event_id,
                    'student_id': evt.get('studentId'),
                    'skill_id': evt.get('skillId'),
                    'question_id': evt.get('questionId'),
                    'is_correct': evt.get('isCorrect', False),
                    'mastery_before': evt.get('masteryBefore', 0.5),
                    'mastery_after': evt.get('masteryAfter', 0.5),
                    'timestamp': evt.get('timestamp', datetime.utcnow().isoformat()),
                    'received_at': datetime.utcnow().isoformat(),
                }
                batch.put_item(Item=item)
                processed += 1

        # Update student mastery aggregates
        _update_student_mastery(events)

        return _response(200, {
            'success': True,
            'processed': processed,
            'duplicates_skipped': duplicates,
            'message': f'Synced {processed} events'
        })

    except json.JSONDecodeError:
        return _response(400, {'error': 'Invalid JSON'})
    except Exception as e:
        print(f"Sync error: {e}")
        return _response(500, {'error': 'Internal server error'})

def _update_student_mastery(events: List[Dict]) -> None:
    """Update aggregated mastery scores per student per skill"""
    # Group by student+skill, take latest mastery_after
    mastery_map = {}
    for evt in events:
        key = (evt.get('studentId'), evt.get('skillId'))
        timestamp = evt.get('timestamp', '')
        if key not in mastery_map or timestamp > mastery_map[key]['timestamp']:
            mastery_map[key] = {
                'student_id': evt.get('studentId'),
                'skill_id': evt.get('skillId'),
                'mastery': evt.get('masteryAfter', 0.5),
                'timestamp': timestamp,
                'updated_at': datetime.utcnow().isoformat()
            }

    with students_table.batch_writer() as batch:
        for (student_id, skill_id), data in mastery_map.items():
            batch.put_item(Item=data)

def _response(status_code: int, body: Dict) -> Dict[str, Any]:
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS'
        },
        'body': json.dumps(body)
    }