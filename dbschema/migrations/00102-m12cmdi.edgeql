CREATE MIGRATION m12cmdi4zlnajsiz4zraaoiwryxsngupdi2nxvsb2qal3yet2ue65a
    ONTO m1povcaokz4mw5iheqqbgwzqbsqyeax4pjo7kl5eaqxdeywbpmumqa
{
  CREATE MODULE analytics IF NOT EXISTS;
  CREATE TYPE analytics::Iteration EXTENDING default::PrimitiveProperty {
      CREATE MULTI LINK designs: design::Revision;
      CREATE REQUIRED LINK project: default::Project;
      CREATE PROPERTY description: std::str {
          CREATE CONSTRAINT std::max_len_value(400);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE REQUIRED PROPERTY name: std::str {
          CREATE CONSTRAINT std::max_len_value(50);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE REQUIRED PROPERTY status: default::StatusCategory {
          SET default := (default::StatusCategory.Ongoing);
      };
      CREATE PROPERTY targetDate: std::datetime;
  };
  CREATE SCALAR TYPE analytics::ObjectiveType EXTENDING enum<ApprovedRequirements, CoveragePlanRequirement, CoverageDesignRequirement, ApprovedPlans, ApprovedDesigns, ValidatedRequirements, ValidatedDesigns>;
  CREATE TYPE analytics::Objective EXTENDING default::PrimitiveProperty {
      CREATE REQUIRED LINK iteration: analytics::Iteration {
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE MULTI LINK filterCategory: default::Category;
      CREATE REQUIRED PROPERTY type: analytics::ObjectiveType;
  };
  ALTER TYPE analytics::Iteration {
      CREATE MULTI LINK objectives := (.<iteration[IS analytics::Objective]);
  };
  ALTER TYPE default::Project {
      CREATE MULTI LINK iterations := (.<project[IS analytics::Iteration]);
      CREATE PROPERTY description: std::str {
          CREATE CONSTRAINT std::max_len_value(400);
      };
      CREATE PROPERTY externalLink1: std::str {
          CREATE CONSTRAINT std::max_len_value(100);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE PROPERTY externalLink2: std::str {
          CREATE CONSTRAINT std::max_len_value(100);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE PROPERTY externalName1: std::str {
          CREATE CONSTRAINT std::max_len_value(30);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE PROPERTY externalName2: std::str {
          CREATE CONSTRAINT std::max_len_value(30);
          CREATE CONSTRAINT std::min_len_value(1);
      };
  };
};
