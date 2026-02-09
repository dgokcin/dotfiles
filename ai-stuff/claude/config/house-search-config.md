# House Search Configuration

## Private Data

Sensitive financial and contact information is in the private config:

@~/.claude/config/_house-search-private.md

## Vault Paths

The Obsidian vault is symlinked at `~/vault/`. All paths below are absolute.

| Path              | Purpose                                                                       |
| ----------------- | ----------------------------------------------------------------------------- |
| **Base**          | `~/vault/personal/nl/house search/buying a house/`                            |
| **Properties**    | `~/vault/personal/nl/house search/buying a house/properties/`                 |
| **Neighborhoods** | `~/vault/personal/nl/house search/buying a house/neighborhoods/`              |
| **MoC**           | `~/vault/personal/nl/house search/buying a house/00 - House Search MoC.md`    |

## Templates

Templates for Obsidian notes are in the `templates/` directory:

- `templates/property-frontmatter.yaml` — Frontmatter schema for property notes
- `templates/property-template.md` — Body structure for property notes
- `templates/neighborhood-template.md` — Structure for neighborhood notes

## Tier System

| Tier       | Frontmatter Value | Meaning                                        |
| ---------- | ----------------- | ---------------------------------------------- |
| Strong Buy | `strong-buy`      | Seriously pursue — request viewing immediately |
| Buy        | `buy`             | Good option worth considering                  |
| Watch      | `watch`           | Interesting but not urgent                     |
| Skip       | `skip`            | Analyzed and rejected                          |

## MoC — Dataview Integration

The MoC at `00 - House Search MoC.md` uses Dataview TABLE queries to auto-display properties by tier. **Do NOT manually add property links to the MoC** — the Dataview queries handle this automatically based on the `tier` frontmatter field.

Each tier section uses this query pattern:

```
TABLE
  "€" + string(price/1000) + "k" AS Price,
  string(size_m2) + " m²" AS Size,
  neighborhood AS Neighborhood,
  energy_label AS Energy,
  choice(erfpacht, "Erfpacht", "Eigen grond") AS Ownership,
  choice(viewing_requested, "✓", "") AS Viewing
FROM "personal/nl/house search/buying a house/properties"
WHERE tier = "<tier-value>"
SORT price ASC
```

To move a property between tiers, just change the `tier` field in the property note's frontmatter.

## Buying Costs to Factor In

- Notary: €2,500
- Valuation: €800
- Technical inspection: €500 (skip if new build)
- Mortgage advice: €3,500
- Estate agent: €5,000
- Transfer tax: 2% (waived if under €555k)
- Total estimated costs: €12,300–€25,000

## Market Intelligence from Mortgage Advisor & Agent

- Funda listings are intentionally priced low to generate competition; overbidding is standard
- My agent works with 14 partner agents — they may have intel on seller expectations
- Best months to buy: July, August, December, January (less competition)
- After winning bid: 4-5 week financial clause period → precontract → mortgage approval → final contract
- Erfpacht reduces mortgage capacity by x20 of the annual canon — this is a dealbreaker at high canons
- Interest is tax deductible (gross €1,975/mo → net ~€1,535/mo at current rates)

## Preferred Locations

| Tier  | Areas                                                             |
| ----- | ----------------------------------------------------------------- |
| Top   | De Pijp, Oud-Zuid, Overtoom area, Vondelpark surroundings         |
| Great | Spaarndammerbuurt, Houthavens, KNSM-eiland, Westerdok             |
| Good  | Other non-touristy ring neighborhoods with character              |
| Avoid | Deep tourist zones (Centrum/Red Light), isolated industrial edges |

## Property Requirements

- Energy label: C or better
- Size: >50m² (ideally >70m²)
- Not ground floor
- Near public transport and daily shopping
- No carpet (allergies)
- Bonuses: balcony, south-facing, bike storage, individual heating control
