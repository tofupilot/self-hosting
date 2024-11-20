CREATE MIGRATION m1n5sxnl7rljadhpit6qkwcg7mg53zhe3lxemgausgdpka4opw22fa
    ONTO m1aomxhi7zqwviopshdtbrkeeuscr4623vemyrh2226rpvaikaqwlq
{
  CREATE TYPE default::Batch EXTENDING default::PrimitiveProperty {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET OWNED;
          SET readonly := true;
          SET TYPE default::Organization;
      };
      CREATE REQUIRED PROPERTY number: std::str {
          CREATE CONSTRAINT std::max_len_value(100);
          CREATE CONSTRAINT std::min_len_value(1);
      };
      CREATE CONSTRAINT std::exclusive ON ((.number, .organization));
  };
  ALTER TYPE default::Unit {
      CREATE LINK batch: default::Batch {
          ON SOURCE DELETE DELETE TARGET IF ORPHAN;
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::Batch {
      CREATE MULTI LINK units := (.<batch[IS default::Unit]);
  };
};
