CREATE MIGRATION m1cvlflvhjxnnqo4sawreusgyaarma7q5xd6us4n4qabbwfoxrenrq
    ONTO m1nlbw2nsbco3zvveqpibr5pq5jmuscdecamugbccrsvethafd2edq
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY IAllowOrgMemberToDoAnything;
      EXTENDING default::PrimitiveProperty LAST;
  };
  ALTER TYPE default::Primitive {
      ALTER PROPERTY createdAt {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER LINK createdBy {
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE default::Action {
      CREATE PROPERTY date := ((.startedAt ?? .createdAt));
      CREATE INDEX ON (.date);
  };
  ALTER TYPE default::Action {
      CREATE LINK unit: default::Unit;
  };
  ALTER TYPE default::Unit {
      CREATE MULTI LINK runs := (.<unit[IS default::Action]);
  };
  ALTER TYPE default::Unit {
      CREATE INDEX ON (.createdAt);
  };
  ALTER TYPE default::TestStepRun {
      CREATE INDEX ON (.createdAt);
      CREATE LINK unit: default::Unit;
  };
};
