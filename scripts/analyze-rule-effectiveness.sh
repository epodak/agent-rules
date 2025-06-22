#!/bin/bash

# Rule Effectiveness Analysis Script
# Analyzes rule usage and generates effectiveness reports

set -e

RULES_DIR="project-rules"
USAGE_LOG="logs/rule-usage.json"
OUTPUT_DIR="reports"

# Create necessary directories
mkdir -p logs reports

echo "🔍 Analyzing Rule Effectiveness..."
echo "================================="

# Function to extract rule metadata
extract_rule_data() {
    local rule_file=$1
    local rule_name=$(basename "$rule_file" .mdc)
    
    echo "📊 Analyzing: $rule_name"
    
    # Count rule references in recent commits (last 30 days)
    local usage_count=$(git log --since="30 days ago" --grep="$rule_name" --oneline | wc -l)
    
    # Calculate file modification frequency when rule is used
    local files_impacted=$(git log --since="30 days ago" --grep="$rule_name" --name-only --pretty=format: | sort -u | wc -l)
    
    # Generate rule score based on usage patterns
    local score=0
    if [ $usage_count -gt 10 ]; then score=$((score + 30)); fi
    if [ $usage_count -gt 5 ]; then score=$((score + 20)); fi
    if [ $files_impacted -gt 3 ]; then score=$((score + 25)); fi
    if [ -f "$USAGE_LOG" ] && grep -q "$rule_name" "$USAGE_LOG"; then score=$((score + 25)); fi
    
    echo "   Usage Count: $usage_count"
    echo "   Files Impacted: $files_impacted" 
    echo "   Effectiveness Score: $score/100"
    echo ""
    
    # Store results
    cat >> "$OUTPUT_DIR/effectiveness-report.json" << EOF
{
  "rule": "$rule_name",
  "score": $score,
  "usage_count": $usage_count,
  "files_impacted": $files_impacted,
  "analyzed_date": "$(date -I)",
  "status": "$([ $score -gt 60 ] && echo "high-value" || echo "needs-review")"
},
EOF
}

# Initialize report
echo "[" > "$OUTPUT_DIR/effectiveness-report.json"

# Analyze each rule
for rule_file in "$RULES_DIR"/*.mdc; do
    if [ -f "$rule_file" ]; then
        extract_rule_data "$rule_file"
    fi
done

# Close JSON array (remove last comma and close)
sed -i '$ s/,$//' "$OUTPUT_DIR/effectiveness-report.json"
echo "]" >> "$OUTPUT_DIR/effectiveness-report.json"

# Generate summary report
echo "📈 RULE EFFECTIVENESS SUMMARY"
echo "=============================="

# Top performing rules
echo "🏆 TOP PERFORMING RULES:"
jq -r '.[] | select(.score > 60) | "  \(.rule): \(.score)/100 (\(.status))"' "$OUTPUT_DIR/effectiveness-report.json" | head -5

echo ""
echo "⚠️  RULES NEEDING ATTENTION:"
jq -r '.[] | select(.score <= 40) | "  \(.rule): \(.score)/100 (\(.status))"' "$OUTPUT_DIR/effectiveness-report.json"

echo ""
echo "📊 USAGE STATISTICS:"
total_rules=$(jq length "$OUTPUT_DIR/effectiveness-report.json")
high_value=$(jq '[.[] | select(.score > 60)] | length' "$OUTPUT_DIR/effectiveness-report.json")
low_value=$(jq '[.[] | select(.score <= 40)] | length' "$OUTPUT_DIR/effectiveness-report.json")

echo "  Total Rules: $total_rules"
echo "  High Value (>60): $high_value ($((high_value * 100 / total_rules))%)"
echo "  Needs Review (≤40): $low_value ($((low_value * 100 / total_rules))%)"

# Generate actionable recommendations
echo ""
echo "🎯 ACTIONABLE RECOMMENDATIONS:"
echo "1. Focus development effort on high-value rules"
echo "2. Review/improve rules scoring ≤40"
echo "3. Document success patterns from top performers"
echo "4. Consider deprecating unused rules"

echo ""
echo "📄 Full report saved to: $OUTPUT_DIR/effectiveness-report.json"
echo "🔄 Next analysis: $(date -d '+7 days' -I)" 