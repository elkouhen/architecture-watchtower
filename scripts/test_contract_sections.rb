# frozen_string_literal: true

require "minitest/autorun"
require_relative "contract_sections"

class ContractSectionsTest < Minitest::Test
  TEXT = <<~MD
    # Contrat

    Préambule.

    ## Preuves et dates

    Règle A.

    ## Algorithme Scanner → Filtrer

    Intro.

    ### 1. Scanner

    Étape 1.

    ### 2. Filtrer

    Étape 2.

    ## Transparence

    Hors phase.
  MD

  def test_extracts_named_sections_only
    text = WatchtowerContractSections.extract(TEXT, ["Preuves et dates", "Algorithme Scanner", "2. Filtrer"])
    assert_equal "## Preuves et dates\n\nRègle A.\n\n## Algorithme Scanner → Filtrer\n\nIntro.\n\n### 2. Filtrer\n\nÉtape 2.\n", text
    refute_includes text, "Hors phase"
    refute_includes text, "Étape 1"
  end

  def test_missing_section_raises
    assert_raises(WatchtowerContractSections::Error) { WatchtowerContractSections.extract(TEXT, ["Inexistante"]) }
  end
end
