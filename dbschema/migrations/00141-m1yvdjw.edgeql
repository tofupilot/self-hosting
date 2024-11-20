CREATE MIGRATION m1yvdjwjwgyjqncfflhrvpj4gajplvitjem7wqchpxv33yg5bqolha
    ONTO m1fr2ugzh7x3rku33otwbpfeifqcrdyx4rjm3kgy5v2xekd46hqmnq
{
  ALTER TYPE default::Primitive {
      ALTER PROPERTY name {
          DROP CONSTRAINT std::max_len_value(200);
      };
  };
  ALTER TYPE default::Primitive {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::max_len_value(300);
      };
  };
};
