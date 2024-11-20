CREATE MIGRATION m1iiac67doykfvg7jmxtomvntujdr3c4ne4m6jisxt4iv7zfdir5nq
    ONTO m1yqvoumqfewx3dn2kilibqhj4woqm4m7piwcwy5nm4hlfqjf76mga
{
  CREATE MODULE relation IF NOT EXISTS;
  CREATE ABSTRACT TYPE relation::Relation EXTENDING default::PrimitiveProperty {
      CREATE REQUIRED LINK from: default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE REQUIRED LINK to: default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK relationsFrom := (.<from[IS relation::Relation]);
      CREATE MULTI LINK relationsTo := (.<to[IS relation::Relation]);
  };
  CREATE TYPE relation::RequirementToDesign EXTENDING relation::Relation {
      ALTER LINK from {
          SET OWNED;
          SET TYPE default::Requirement USING (<default::Requirement>{});
      };
      ALTER LINK to {
          SET OWNED;
          SET TYPE default::Design USING (<default::Design>{});
      };
      CREATE MULTI LINK proofs: default::Action;
  };
};
