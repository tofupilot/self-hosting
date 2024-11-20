CREATE MIGRATION m1imorjjaxektph7aqbltq6vwyylyf3lztpgczkqz2hta5twa26sqa
    ONTO m1yn5gz3fdojqwwr33kylcdpxzuxsu76ds6yhz5optsmh74etjotta
{
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY server_can_list2
          ALLOW SELECT USING (EXISTS (GLOBAL default::currentUserId));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY server_can_list_and_insert RENAME TO server_can_list;
  };
};
