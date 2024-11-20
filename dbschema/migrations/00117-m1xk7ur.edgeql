CREATE MIGRATION m1xk7ur4wf6p5ier4ae2e5f45inp6inywazti2da4ivrwaxnvuk7ma
    ONTO m1rjipzokgudzoqh24idnv2sm3ia5m574nkplabku6lyvvq3ljcwvq
{
  ALTER TYPE default::Organization {
      CREATE PROPERTY copilotFeatureFlag: std::bool {
          SET default := false;
      };
  };
};
