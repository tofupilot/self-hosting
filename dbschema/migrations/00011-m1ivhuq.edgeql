CREATE MIGRATION m1ivhuqsrdgn6jpmrefd3w2ipl74i3u7ykjahvqnshotkt4rvzlp2a
    ONTO m13ayduzkc5qgkgtzfbckxa5xe6h4jekj5siqahntpgnjnoh6fphza
{
  ALTER TYPE default::Primitive {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
  ALTER TYPE default::Label {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
  ALTER TYPE default::Organization {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
  ALTER TYPE default::Project {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
  ALTER TYPE default::Status {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
  };
};
