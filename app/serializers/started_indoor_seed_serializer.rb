class StartedIndoorSeedSerializer
  include JSONAPI::Serializer
  attributes  :id,
              :name,
              :plant_type,
              :days_relative_to_frost_date,
              :recommended_transplant_date,
              :days_to_maturity,
              :hybrid_status,
              :organic,
              :planting_status,
              :start_from_seed,
              :direct_seed,
              :recommended_seed_sewing_date,
              :actual_seed_sewing_date,
              :seedling_days_to_transplant,
              :projected_seedling_transplant_date,
              :actual_transplant_date
end