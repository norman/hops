<% for name, t in pairs(app) do -%>
  <h2><%= name %></h2>
  <ul>
    <% if type(t) == "table" then -%>
      <% for k, v in pairs(t) do -%>
        <li><%= string.format("%s = %s", tostring(k), tostring(v)) %></li>
      <% end -%>
    <% else -%>
      <li><%= tostring(t) %></li>
    <% end -%>
  </ul>
<% end -%>
