CREATE MIGRATION m14wod7hmefn66ekwudxwbyaeclqrlx4wmmmhaqth24pvuwh2csu3q
    ONTO m1wulcjecmmqeo722zn6z2awt5ixvmm6yk6nfglwlbwe7vajodm63q
{
  CREATE MODULE activity IF NOT EXISTS;
  CREATE ABSTRACT TYPE activity::Activity {
      CREATE REQUIRED LINK actor -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
      CREATE REQUIRED PROPERTY timestamp -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
  CREATE TYPE activity::UserVisitActivity EXTENDING activity::Activity {
      CREATE PROPERTY page -> std::str {
          SET readonly := true;
      };
  };
  CREATE ABSTRACT TYPE default::Activity {
      CREATE REQUIRED LINK actor -> default::User;
      CREATE REQUIRED PROPERTY action -> std::str;
      CREATE REQUIRED PROPERTY timestamp -> std::datetime {
          SET default := (<std::datetime>std::datetime_current());
      };
  };
  CREATE TYPE default::LabelChangeActivity EXTENDING default::Activity {
      CREATE REQUIRED MULTI LINK newLabels -> default::Label;
      CREATE REQUIRED MULTI LINK oldLabels -> default::Label;
      CREATE REQUIRED LINK primitive -> default::Primitive;
  };
  CREATE TYPE default::StatusChangeActivity EXTENDING default::Activity {
      CREATE REQUIRED LINK newStatus -> default::Status;
      CREATE REQUIRED LINK oldStatus -> default::Status;
      CREATE REQUIRED LINK primitive -> default::Primitive;
  };
  CREATE TYPE default::UserSessionActivity EXTENDING default::Activity {
      CREATE PROPERTY session_end -> std::datetime;
      CREATE REQUIRED PROPERTY session_start -> std::datetime;
  };
};
