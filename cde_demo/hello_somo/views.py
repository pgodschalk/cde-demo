from django.http import HttpResponse


def index(request):
    return HttpResponse("<h1>Hey, Solar Monkey! 🐵😄</h1>")
