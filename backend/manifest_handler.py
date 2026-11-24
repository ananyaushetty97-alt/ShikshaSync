import json
import boto3
import os
from typing import Dict, Any

s3 = boto3.client('s3', region_name=os.environ.get('AWS_REGION', 'us-east-1'))
dynamodb = boto3.resource('dynamodb', region_name=os.environ.get('AWS_REGION', 'us-east-1'))

LESSONS_BUCKET = os.environ.get('S3_LESSON_PACKS_BUCKET', 'shikshasync-lesson-packs')
LESSONS_TABLE = os.environ.get('DYNAMODB_LESSONS_TABLE', 'shikshasync-lessons')
lessons_table = dynamodb.Table(LESSONS_TABLE)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    GET /manifest - Return list of available lesson packs
    Query params: ?grade=6&language=kn&subject=math
    """
    try:
        # Parse query parameters
        params = event.get('queryStringParameters') or {}
        grade = params.get('grade')
        language = params.get('language')
        subject = params.get('subject')

        # Build filter
        filter_expr = []
        expr_values = {}

        if grade:
            filter_expr.append('#g = :grade')
            expr_values[':grade'] = int(grade)
        if language:
            filter_expr.append('#l = :lang')
            expr_values[':lang'] = language
        if subject:
            filter_expr.append('#s = :subj')
            expr_values[':subj'] = subject

        scan_kwargs = {
            'ProjectionExpression': 'pack_id, #g, #s, #l, skills, version, updated_at, size_bytes',
            'ExpressionAttributeNames': {
                '#g': 'grade',
                '#s': 'subject',
                '#l': 'language'
            }
        }

        if filter_expr:
            scan_kwargs['FilterExpression'] = ' AND '.join(filter_expr)
            scan_kwargs['ExpressionAttributeValues'] = expr_values

        # Scan lessons table
        response = lessons_table.scan(**scan_kwargs)
        packs = response.get('Items', [])

        # Add download URLs (pre-signed or CloudFront)
        for pack in packs:
            pack['download_url'] = f"https://{LESSONS_BUCKET}.s3.amazonaws.com/{pack['pack_id']}.zip"
            # Or CloudFront: pack['download_url'] = f"https://{CLOUDFRONT_DOMAIN}/{pack['pack_id']}.zip"

        return _response(200, {
            'packs': packs,
            'count': len(packs)
        })

    except Exception as e:
        print(f"Manifest error: {e}")
        return _response(500, {'error': 'Internal server error'})

def _response(status_code: int, body: Dict) -> Dict[str, Any]:
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET, OPTIONS'
        },
        'body': json.dumps(body, default=str)
    }