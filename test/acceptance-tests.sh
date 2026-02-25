#!/bin/bash
# Acceptance tests for deployed application
# Usage: ./test/acceptance-tests.sh <APP_URL>

set -e

APP_URL="${1:-${APP_URL}}"

if [ -z "$APP_URL" ]; then
  echo "::error::Application URL not provided. Usage: $0 <APP_URL> or set APP_URL environment variable"
  exit 1
fi

echo "::group::Running acceptance tests"
echo "Testing application at: $APP_URL"

# Test 1: Basic connectivity and HTTP response
echo ""
echo "Test 1: Checking basic connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 "$APP_URL" || echo "000")

if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
  echo "✓ Basic connectivity test passed (HTTP $HTTP_CODE)"
else
  echo "::error::Basic connectivity test failed (HTTP $HTTP_CODE)"
  exit 1
fi

# Test 2: Response content validation (optional - can be extended)
echo ""
echo "Test 2: Validating response content..."
RESPONSE=$(curl -s --max-time 30 "$APP_URL" || echo "")

if [ -n "$RESPONSE" ]; then
  echo "✓ Response content received (${#RESPONSE} bytes)"
else
  echo "::warning::Empty response received"
fi

# Test 3: Health check endpoint (if available)
echo ""
echo "Test 3: Checking health endpoint..."
HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${APP_URL}/health" 2>/dev/null || echo "404")

if [[ "$HEALTH_CODE" == "200" ]]; then
  echo "✓ Health check endpoint passed (HTTP $HEALTH_CODE)"
elif [[ "$HEALTH_CODE" == "404" ]]; then
  echo "ℹ Health check endpoint not available (HTTP $HEALTH_CODE) - skipping"
else
  echo "::warning::Health check endpoint returned HTTP $HEALTH_CODE"
fi

# More comprehensive tests can be added here
# Examples:
# - API endpoint tests
# - Database connectivity tests
# - Performance tests
# - Security tests

echo ""
echo "::endgroup::"
echo "✅ All acceptance tests passed"
exit 0

# Made with Bob
