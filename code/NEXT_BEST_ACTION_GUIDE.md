# Next Best Action Skill - Agent Configuration Guide

## Overview

Build on top of the **Account Brief** foundation to create a **Next Best Action Recommender** skill that prioritizes and contextualizes recommendations - **without deploying any additional Apex code**.

This guide shows how to use agent reasoning with the existing `Get Account Context` action to deliver intelligent, prioritized recommendations.

## The Approach: Agent Reasoning (No Code!)

Instead of building complex scoring algorithms in Apex, leverage the agent's natural language reasoning:

1. ✅ **Reuse** the existing `Get Account Context` action
2. ✅ **Add instructions** to analyze the JSON and recommend actions
3. ✅ **Let the agent reason** about patterns, urgency, and impact

**Why This Works:**
- No additional Apex deployment
- No Account_Priority__c records required (works with standard objects only)
- Agent can explain nuances that code can't
- Easy to iterate - just update prompts, no redeploy
- Adapts to varying data availability per account

## Quick Test

Try this prompt with your agent right now:

```
Analyze the account brief for DEMO Lakeshore Medical Group and 
recommend the top 3 actions I should take this week. For each 
recommendation, explain why it matters and cite specific data.
```

The agent should:
1. Call `Get Account Context` automatically
2. Parse the returned JSON
3. Identify patterns (declining spend, near-term opportunities, open issues)
4. Return prioritized recommendations with evidence

## Skill Configuration

### Topic Setup

**Topic Name**: "Account Strategy and Recommendations"

**Description**: 
"Provides strategic recommendations and next best actions for customer accounts based on comprehensive account analysis"

**Sample Utterances**:
- "What should I focus on for [account name]"
- "Give me recommendations for [account name]"
- "What are the priorities for [account name]"
- "What should I do next with [account name]"
- "Top actions for [account name]"

### Instructions for Agent

Add these instructions to your agent's system prompt or topic instructions:

```
# Next Best Action Recommendations

When the user asks for recommendations, priorities, or what to focus on:

1. DATA RETRIEVAL
   Call Get_Account_Context with the account name or ID to retrieve comprehensive data

2. ANALYZE FOR SIGNALS
   Examine the returned JSON for:
   
   Orders & Revenue:
   - Trend: Is trailing12MonthTotal increasing, flat, or declining?
   - Pattern: Are order amounts/frequency changing over time?
   - Volume: Compare recent months vs. older months
   
   Opportunities:
   - Pipeline: How many open opportunities? Total value?
   - Urgency: Any closing in the next 30/60/90 days?
   - Stage: Which ones are in late stages (Negotiation, Value Proposition)?
   - Recent wins: Any closed-won opportunities showing momentum?
   
   Cases & Issues:
   - Open cases: Any urgent or high-priority issues?
   - Pattern: Single issue or recurring problems?
   - Type: Delivery, quality, billing, support?
   
   Relationships:
   - Contacts: How many key contacts? Recent activity?
   - Engagement: Multiple stakeholders or narrow relationship?
   
   Data Gaps:
   - Missing array: What data is unavailable?
   - Does this indicate risk or opportunity?

3. PRIORITIZATION FRAMEWORK
   Score each potential action on:
   
   URGENCY (High/Medium/Low):
   - High: <30 days to deadline, open critical issue, rapid decline
   - Medium: 30-90 days, moderate issue, flat trend
   - Low: >90 days, no immediate pressure
   
   IMPACT (High/Medium/Low):
   - High: Large revenue, contract renewal, relationship risk
   - Medium: Moderate revenue, expansion opportunity
   - Low: Small value, maintenance task
   
   EFFORT (Quick/Moderate/Complex):
   - Quick: Single call, resolve case, follow up
   - Moderate: Schedule review, proposal needed
   - Complex: Multiple meetings, cross-team coordination

4. RECOMMENDATION FORMAT
   Return 3-5 recommendations in this format:
   
   [Priority Number]. [Action Statement] ([Timing])
      Why: [Specific reason grounded in data]
      Evidence: [Cite numbers from the account data]
      Impact: [Revenue/relationship outcome]
      Suggested next step: [Concrete action]

5. REASONING GUIDELINES
   - Lead with urgent + high impact
   - Cite specific numbers (amounts, dates, counts)
   - Connect patterns to business outcomes
   - Suggest concrete next steps
   - Acknowledge data limitations when present
   - If minimal data exists, say so (don't fabricate recommendations)

6. EXAMPLE OUTPUT STRUCTURE

   "Here are the top 3 priorities for [Account Name]:
   
   1. 🎯 [Action] (This week)
      Why: [Pattern observed in data]
      Evidence: [Specific numbers]
      Impact: [Business outcome]
      Next step: [Concrete action]
   
   2. ⚠️ [Action] (Next 30 days)
      Why: [Urgency factor]
      Evidence: [Data points]
      Impact: [Risk or opportunity]
      Next step: [What to do]
   
   3. 🚀 [Action] (This quarter)
      Why: [Strategic rationale]
      Evidence: [Supporting data]
      Impact: [Expected result]
      Next step: [Action item]
   
   Account Health Score: [X/10] based on [criteria]"

7. HANDLING SPARSE DATA
   If the account has minimal data:
   - Acknowledge: "This account has limited activity data"
   - Focus on available signals (even 1-2 recommendations)
   - Suggest data-gathering actions first
   - Don't fabricate patterns that aren't there
```

## Example Conversations

### Example 1: Full Context Available

**User**: "What should I focus on for DEMO Lakeshore Medical Group?"

**Agent Response**:
```
I'll analyze the comprehensive account data for Lakeshore Medical Group.

[Calls Get_Account_Context]

Here are your top 3 priorities:

1. 🎯 Accelerate 5 near-term opportunities (Next 2 weeks)
   Why: You have $143,500 in pipeline closing in the next 15-60 days
   Evidence: 
   - $65k Emergency Room Upgrade (45 days, Needs Analysis stage)
   - $18k Waiting Room Seating (15 days, Value Proposition)
   - $8.5k Office Supplies (10 days, Negotiation/Review)
   Impact: Quick revenue realization, maintain momentum
   Next step: Schedule check-in calls for top 3 opportunities this week

2. ⚠️ Address declining spend pattern (This week)
   Why: Order volume trending down 25% over 12 months
   Evidence: Orders decreased from $10k/month to $7.5k/month
   Impact: Risk to $340k annual relationship
   Next step: Schedule account review meeting; may connect to open 
             "Furniture delivery delay" case
   
3. 🚀 Leverage recent wins for expansion (This month)
   Why: Just closed $120k contract renewal showing strong trust
   Evidence: 2 closed-won deals in last 3 months totaling $148k
   Impact: Warm relationship, receptive to new offerings
   Next step: Present complementary products/services

Account Health: 7.5/10 - Strong pipeline but declining order trend 
needs attention
```

### Example 2: Sparse Data

**User**: "What should I focus on for DEMO Harbor Supply Co?"

**Agent Response**:
```
[Calls Get_Account_Context]

This account has limited activity data (1 contact, 1 open opportunity, 
no order history). Here are my recommendations:

1. 🎯 Advance the single open opportunity (Next 30 days)
   Why: $12k "Harbor Seattle - Office Setup" is the only active pipeline
   Evidence: Currently in Qualification stage, closes in 45 days
   Next step: Move to Needs Analysis, schedule discovery call

2. 📊 Build relationship depth (Next 60 days)
   Why: Only 1 contact on file limits visibility and reach
   Evidence: Only contact is William Johnson (Owner)
   Next step: Request introductions to 2-3 additional stakeholders

3. ⚠️ Note: Potential duplicate account
   Why: Two "DEMO Harbor Supply Co" accounts exist (Seattle and Tacoma)
   Next step: Verify if these are the same company and consolidate if needed

Account Health: 3/10 - Minimal engagement, needs relationship building
```

## Testing Your Configuration

### Test Prompts

Try these with your configured agent:

1. **Basic recommendation request**:
   - "What should I focus on for Lakeshore?"
   - "Give me priorities for Ridgeway Logistics"

2. **Specific timeframe**:
   - "What should I do this week for Lakeshore?"
   - "What are the urgent actions for Ridgeway?"

3. **Sparse data handling**:
   - "Recommendations for Harbor Supply"
   - "What should I focus on for Pinecrest School District?"

4. **Comparison** (if multi-account):
   - "Compare priorities for Lakeshore vs Ridgeway"

### Expected Behavior

✅ **Good Response**:
- Calls `Get Account Context` action
- Cites specific data (numbers, dates, amounts)
- Prioritizes by urgency + impact
- Provides concrete next steps
- Acknowledges data limitations when present

❌ **Poor Response**:
- Generic advice not grounded in data
- No specific numbers or evidence
- Doesn't call the action (missing data)
- Fabricates recommendations when data is sparse

## Iteration Tips

### If recommendations are too generic:
→ Strengthen the "cite specific numbers" instruction
→ Add examples showing evidence citation

### If agent doesn't prioritize well:
→ Make the urgency/impact/effort framework more explicit
→ Add scoring rubric (assign points, show math)

### If agent calls action repeatedly:
→ Add: "Call Get_Account_Context ONCE per account"
→ Check if caching is working

### If recommendations miss patterns:
→ Add specific pattern examples to instructions
→ Show sample analysis: "12 orders, first $10k, last $7.5k = declining"

## Advanced: Hybrid Approach

If pure agent reasoning isn't specific enough, you can add lightweight Apex:

**Option A: Pre-Score the Data**
- Create `AccountScoreService` (~100 lines)
- Apply simple rules: orders declining = -1, close date <30 = +2, open case = -1
- Return scored/flagged JSON
- Let agent explain scores in natural language

**Option B: Computed Insights**
- Extend `AccountContextService` to add computed fields:
  - `orderTrend`: "INCREASING", "FLAT", "DECLINING"
  - `urgencyScore`: 1-10
  - `daysUntilNextRenewal`: integer
- Return richer JSON
- Agent uses computed values in reasoning

**When to add code**: Only if testing shows agent reasoning alone isn't sufficient

## Metrics to Track

Once deployed, measure:

1. **Adoption**: How often sellers ask for recommendations
2. **Follow-through**: Do they take the suggested actions?
3. **Accuracy**: Are recommendations relevant and useful?
4. **Outcome**: Do recommended actions lead to opportunity progression?

Track in Salesforce:
- Create a custom object `Agent_Recommendation__c` to log suggestions
- Link to Account and Opportunity
- Track `Action_Taken__c` (checkbox)
- Track `Outcome__c` (picklist)

## Cost Considerations

**Token Usage per Recommendation Request**:
- Account Context action call: ~500 tokens (Apex execution)
- Account Context JSON response: ~2,000-5,000 tokens (depending on data volume)
- Agent reasoning: ~1,500-3,000 tokens (analysis + formatting)
- **Total**: ~4,000-8,500 tokens per request

**Compared to multiple follow-up questions**:
- Old flow: "Tell me about Lakeshore" → "Show opportunities" → "What's urgent?" = 3 turns
- New flow: "What should I focus on for Lakeshore?" = 1 turn
- **Net savings**: 60-70% fewer tokens, better user experience

## Summary

**What You Built**:
1. ✅ Account Brief skill (Apex action deployed)
2. ✅ Next Best Action skill (agent reasoning configured)

**No Additional Deployment Needed**:
- Reuses existing Apex action
- Works with standard object data
- Configured via agent instructions only

**To Deploy**:
1. Add topic to your agent
2. Add sample utterances
3. Copy instructions into agent configuration
4. Test with DEMO accounts
5. Iterate based on results

**Result**: Intelligent, prioritized recommendations grounded in account data, delivered in natural language, without writing a single new line of Apex code!

---

**Requires**: Account Brief skill deployed  
**Effort**: 30-60 minutes configuration  
**Code Required**: None (pure prompt engineering)
