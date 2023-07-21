# GardenPlants are objects that the user has decided to plant.
class GardenPlant < ApplicationRecord
  validates_presence_of :recommended_transplant_date,
                        :recommended_seed_sewing_date,
                        :seedling_days_to_transplant,
                        :planting_status,
                        :seed_sew_type

  validates :direct_seed_recommended, inclusion: [true, false]
  validates :start_from_seed, inclusion: [true, false]
  validates :actual_transplant_date, presence: {
    message: "You must specify a transplant date!" }, unless: -> { 
      ["transplanted_outside", "direct_sewn_outside"].exclude?(planting_status)
    }
  validates :actual_seed_sewing_date, presence: {
    message: "You must specify a seed-sewing date!" }, unless: -> {
      ["started_indoors"].exclude?(planting_status)
    }
  

  belongs_to :plant

  enum hybrid_status: [:unknown, :open_pollinated, :f1]
  enum planting_status: [:not_started, :started_indoors,
    :direct_sewn_outside, :transplanted_outside]
  enum seed_sew_type: [:not_specified, :not_applicable, :direct, :indirect]
  enum harvest_period: [:season_long, :four_week, :three_week, :two_week, :one_week, :one_time]

  before_save :update_planting_dates, if: :actual_seed_sewing_date_changed?
  after_initialize :update_direct_seed_dates, if: :status_changed_from_not_started_to_direct_sewn

  # A GardenPlant requires fields that must be filled in and calculated by
  # the data in the guides.  This triggers the process after #create is called.
  after_initialize :seed_sew_type_not_applicable, if: :start_from_seed_false
  after_initialize :generate_key_plant_dates, unless: :skip_callbacks
  after_initialize :add_seed_recommendation, unless: :skip_callbacks
  after_initialize :set_new_transplant, if: :immediate_transplant
  after_initialize :future_transplant, if: :qualified_future_transplant
  after_initialize :set_started_indoors, if: :started_indoors
  after_initialize :set_direct_sewn, if: :direct_sewn
  after_initialize :set_direct_future_sew_seed, if: :direct_future_sew

  def update_planting_dates
    self.recommended_transplant_date = actual_seed_sewing_date + seedling_days_to_transplant
  end

  def generate_key_plant_dates
    user = self.plant.user

    default_seed_data = user.plant_guides.find_by(plant_type: plant.plant_type).seedling_days_to_transplant
    self.recommended_transplant_date = user.spring_frost_date.to_date + plant.days_relative_to_frost_date
    self.recommended_seed_sewing_date = user.spring_frost_date.to_date + plant.days_relative_to_frost_date - default_seed_data
    self.seedling_days_to_transplant = default_seed_data
    self.harvest_start = self.recommended_transplant_date + plant.days_to_maturity

    harvest_period = user.plant_guides.find_by(plant_type: plant.plant_type).harvest_period
    self.harvest_period = harvest_period

    case harvest_period
    when "season_long"
      self.harvest_finish = user.fall_frost_date.to_date
    when "four_week"
      self.harvest_finish = self.harvest_start + 28
    when "three_week"
      self.harvest_finish = self.harvest_start + 21
    when "two_week"
      self.harvest_finish = self.harvest_start + 14
    when "one_week"
      self.harvest_finish = self.harvest_start + 7
    when "one_time"
      self.harvest_finish = self.harvest_start
    end
  end

  def add_seed_recommendation
    default_seed_data = self.plant.user.plant_guides.find_by(plant_type: plant.plant_type)
    self.direct_seed_recommended = default_seed_data.direct_seed_recommended
  end

  def set_new_transplant
    self.planting_status = "transplanted_outside"
  end

  def future_transplant
    self.planting_status = "not_started"
    self.recommended_seed_sewing_date = nil
  end

  def seed_sew_type_not_applicable
    self.seed_sew_type = :not_applicable
  end

  def set_started_indoors
    self.planting_status = "started_indoors"
  end

  def set_direct_sewn
    self.planting_status = "direct_sewn_outside"
  end

  def set_direct_future_sew_seed
    self.recommended_seed_sewing_date = self.recommended_transplant_date
  end

  def update_direct_seed_dates
    self.actual_seed_sewing_date = self.actual_transplant_date
  end
  
private
  def immediate_transplant
    !self.actual_transplant_date.nil? && self.start_from_seed == false
  end

  def qualified_future_transplant
    self.start_from_seed == false && self.actual_transplant_date.nil?
  end

  def start_from_seed_false
    self.start_from_seed == false
  end

  def started_indoors
    self.seed_sew_type == "indirect" && !self.actual_seed_sewing_date.nil? && self.actual_transplant_date.nil?
  end

  def direct_sewn
    self.seed_sew_type == "direct" && !self.actual_seed_sewing_date.nil?
  end

  def direct_future_sew
    self.seed_sew_type == "direct" && actual_seed_sewing_date.nil?
  end

  def status_changed_from_not_started_to_direct_sewn
    planting_status_changed?(from: "not_started", to: "direct_sewn_outside")
  end
end
