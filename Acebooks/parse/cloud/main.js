// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  //response.success("Hello world!");
  var jsondata = require('cloud/textbookinfo.js');
  jsondata = jsondata.extractedData;
  var course = request.params.coursename;
  course = jsondata[course];
  response.success(course['Alan Ward']['textbooks']);

});

Parse.Cloud.define("getGoogleImgByCoursename", function(request, response){
  
  var gUrl = 'https://www.googleapis.com/books/v1/volumes?q='
  var suffix = '&fields=items(volumeInfo(authors%2CimageLinks%2CindustryIdentifiers%2Ctitle))'

  gUrl = gUrl + request.params.booktitle + suffix;
  
  Parse.Cloud.httpRequest({
    url: gUrl,
    headers: {
      'Content-Type': 'application/json;charset=utf-8'
    },
    success:function(httpResponse){
      var dict = httpResponse.data;

      var rlist = [];
      if ('items' in dict){
        var items = data['items'];

        for(var index = 0; index < items.length; index++){
          var item = items[index];

          if ('volumeInfo' in item){
            item = item['volumeInfo'];
  
            var rdict = {};
            if ('title' in item){
              rdict['title'] = item['title'];
            }
              
            if('authors' in item){
              rdict['authors'] = item['authors'];
            }
              
            if ('imageLinks' in item){
              var image = item['imageLinks'];
              image = image['thumbnail'];
              rdict['imageLinks'] = image;
            }
              
            if ('industryIdentifiers' in item){
              var identifiers = item['industryIdentifiers'];

              for(var i = 0; i < identifiers.length; i++){
                var exDict = identifiers[i];
                if (exDict['type'] == 'ISBN_13'){
                  rdict['isbn'] = exDict['identifier'];
                }
              }
            }
            rlist.append(rdict);
          }
        }
      }
      response.success(rlist);
      
    },
    error: function(httpResponse){
      response.error('Request failed with response code ' + httpResponse.status);
    }
  });
});
Parse.Cloud.define("getGoogleImgByISBN", function(request, response){
  var ur = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + request.params.isbn;
  	
  Parse.Cloud.httpRequest({
  	url: ur,
    /*header might not work; added later--not tested*/
    headers: {
      'Content-Type': 'application/json;charset=utf-8'
    },
  	success: function(httpResponse) {
  	    var dict = httpResponse.data;
  	    var array = ['items','volumeInfo','imageLinks','thumbnail'];

  	    for(var i = 0; i < array.length; i++ ){
  	    	var key = array[i];
  	    	if (key in dict){
  	    		dict = dict[key]
  	    		if (i == 0){
  	    			dict = dict[0]; //items (key)
  	    		}
  	    		
  	    	}else{
  	    		return; //give us an error (code: 141) that success/error is not called
  	    	}
  	    }

  	 	//dict now contains the url to the image from google books
  	    Parse.Cloud.httpRequest({
  	    	url: dict,
  	    }).then(function(res){
			var file = new Parse.File("image.jpg", {base64: res.buffer.toString('base64')});
			file.save().then(function(){
				var parsefile = new Parse.Object("ParseFiles");
				parsefile.set("isbn", request.params.isbn);
				parsefile.set("imagefile", file);
				parsefile.save();
				response.success("file saved successfully");
			}, function(error){
				response.error(error);
			});

  	    });
 
  	},
  	error: function(httpResponse) {
    	response.error('Request failed with response code ' + httpResponse.status);
  	}
  });
});