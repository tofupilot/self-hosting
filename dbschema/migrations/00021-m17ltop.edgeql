CREATE MIGRATION m17ltopayqneirzhnaqslwsbthbz3c47hnugdowukoe3xbav5h2y7a
    ONTO m1rbtp2uritqecpzs52h4wt4jkq6s4saxvy33tgz2kok6ttph3flhq
{
  ALTER TYPE default::Primitive {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(100);
      };
  };
  ALTER TYPE default::Label {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
  ALTER TYPE default::Organization {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
  ALTER TYPE default::Project {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
  ALTER TYPE default::Status {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
  ALTER TYPE default::Upload {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(255);
      };
  };
  ALTER TYPE default::User {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
};
