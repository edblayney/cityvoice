function padToThree(number) {
    var str = "" + 1;
    var pad = "000";
    var ans = pad.substring(0, pad.length - number.length) + number;
    return ans;
}

Cityvoice.Models.Location = Backbone.Model.extend({
  toLatLng: function(){
    var coordinates = this.get("geometry").coordinates;
    return L.latLng(coordinates[1], coordinates[0]);
  },
  toContent: function(){
    var properties = this.get("properties");
    return ['<a href="', properties.url, '">', properties.name, '</a><br>Call-in Code: ', padToThree(properties.id), ''].join("");
  }
});
